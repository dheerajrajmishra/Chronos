from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from presidio_analyzer import AnalyzerEngine
from presidio_anonymizer import AnonymizerEngine
from presidio_anonymizer.entities import OperatorConfig
import redis
import uuid
import os

app = FastAPI()

analyzer = AnalyzerEngine()
anonymizer = AnonymizerEngine()

# Connect to Redis
redis_client = redis.Redis(host=os.environ.get('REDIS_HOST', 'redis'), port=6379, db=0, decode_responses=True)

class MaskRequest(BaseModel):
    workflow_id: str
    text: str

class UnmaskRequest(BaseModel):
    workflow_id: str
    text: str

@app.post("/mask")
def mask_data(req: MaskRequest):
    results = analyzer.analyze(text=req.text, entities=["API_KEY", "IP_ADDRESS", "PERSON", "CREDIT_CARD", "EMAIL_ADDRESS"], language='en')
    
    # Custom anonymization to replace with deterministic tokens
    operators = {}
    tokens = {}
    
    for res in results:
        entity_type = res.entity_type
        operators[entity_type] = OperatorConfig("custom", {"lambda": lambda x: f"<{entity_type}_{uuid.uuid4().hex[:6].upper()}>"})

    anonymized_result = anonymizer.anonymize(text=req.text, analyzer_results=results, operators=operators)
    
    # Save the original vs token mapping in Redis for this workflow
    for item in anonymized_result.items:
        original = req.text[item.start:item.end]
        token = item.text
        # Redis hash mapping for unmasking
        redis_client.hset(f"vault:{req.workflow_id}", token, original)
        
    return {"masked_text": anonymized_result.text}

@app.post("/unmask")
def unmask_data(req: UnmaskRequest):
    text = req.text
    mapping = redis_client.hgetall(f"vault:{req.workflow_id}")
    
    for token, original in mapping.items():
        text = text.replace(token, original)
        
    return {"unmasked_text": text}
