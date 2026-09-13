import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { query } from '../db';

const JWT_SECRET = process.env.JWT_SECRET || 'zero-trust-super-secret-key-2026';

export interface AuthRequest extends Request {
  user?: {
    id: number;
    email: string;
    is_system_admin: boolean;
    tenant_id: number;
    role: string;
  };
}

export const requireAuth = async (req: AuthRequest, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized: Missing or invalid token' });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET) as any;
    
    // We assume the token encodes the currently active tenant
    const { id, email, is_system_admin, tenant_id, role } = decoded;

    req.user = { id, email, is_system_admin, tenant_id, role };
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Unauthorized: Expired or invalid token' });
  }
};

export const requireRole = (roles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    if (req.user.is_system_admin) {
      return next(); // System admins can do anything
    }
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden: Insufficient role permissions' });
    }
    next();
  };
};

// Generates a JWT token for a user and a specific tenant context
export const generateToken = (user: any, tenant_id: number, role: string) => {
  return jwt.sign(
    {
      id: user.id,
      email: user.email,
      is_system_admin: user.is_system_admin,
      tenant_id,
      role
    },
    JWT_SECRET,
    { expiresIn: '24h' }
  );
};
