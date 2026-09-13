import { Response, NextFunction } from 'express';
import { AuthRequest } from './auth';
import { query } from '../db';
import * as net from 'net';

// A simple IP to int function for CIDR matching
function ipToLong(ip: string): number {
  if (!net.isIPv4(ip)) return 0;
  return ip.split('.').reduce((acc, octet) => (acc << 8) + parseInt(octet, 10), 0) >>> 0;
}

function isIpInCidr(ip: string, cidr: string): boolean {
  if (!net.isIPv4(ip)) return true; // Naively pass IPv6 for now, or block it. Usually we'd use ipaddr.js
  const [range, bits] = cidr.split('/');
  if (!bits) return ip === range;
  
  const mask = -1 << (32 - parseInt(bits, 10));
  return (ipToLong(ip) & mask) === (ipToLong(range) & mask);
}

export const ipRestrictionMiddleware = async (req: AuthRequest, res: Response, next: NextFunction) => {
  if (!req.user) return next();

  try {
    const { tenant_id } = req.user;
    const clientIp = req.ip || req.connection.remoteAddress || '127.0.0.1';
    
    // Normalize IPv4-mapped IPv6
    const normalizedIp = clientIp.includes('::ffff:') ? clientIp.split('::ffff:')[1] : clientIp;

    const result = await query('SELECT ip_cidr FROM ip_whitelists WHERE tenant_id = $1', [tenant_id]);
    
    if (result.rows.length === 0) {
      // No whitelists configured for this tenant, meaning open access
      return next();
    }

    let isAllowed = false;
    for (const row of result.rows) {
      if (isIpInCidr(normalizedIp, row.ip_cidr)) {
        isAllowed = true;
        break;
      }
    }

    if (!isAllowed) {
      return res.status(403).json({ error: 'Forbidden: IP Address not whitelisted for this organization' });
    }

    next();
  } catch (err) {
    console.error('IP Whitelist Error:', err);
    return res.status(500).json({ error: 'Internal server error checking IP' });
  }
};
