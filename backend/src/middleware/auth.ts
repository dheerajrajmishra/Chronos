import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { query, ROLE_PERMISSIONS } from '../db';

const JWT_SECRET = process.env.JWT_SECRET || 'zero-trust-super-secret-key-2026';

export interface AuthRequest extends Request {
  user?: {
    id: number;
    email: string;
    name: string;
    is_system_admin: boolean;
    tenant_id: number;
    role: string;
    permissions: Record<string, boolean>;
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
    const { id, email, name, is_system_admin, tenant_id, role, permissions } = decoded;

    req.user = { id, email, name: name || '', is_system_admin, tenant_id, role, permissions: permissions || {} };
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

// Requires system_admin flag (Chronos platform-level admin)
export const requireSystemAdmin = (req: AuthRequest, res: Response, next: NextFunction) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  if (!req.user.is_system_admin) {
    return res.status(403).json({ error: 'Forbidden: System administrator access required' });
  }
  next();
};

// Requires a specific permission (checks role defaults + user overrides)
export const requirePermission = (permission: string) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    // System admins bypass all permission checks
    if (req.user.is_system_admin) {
      return next();
    }
    
    // Check user-level permission overrides first
    if (req.user.permissions && req.user.permissions[permission] !== undefined) {
      if (req.user.permissions[permission]) {
        return next();
      }
      return res.status(403).json({ error: `Forbidden: Missing permission '${permission}'` });
    }

    // Fall back to role-based defaults
    const rolePerms = ROLE_PERMISSIONS[req.user.role];
    if (rolePerms && rolePerms[permission]) {
      return next();
    }

    return res.status(403).json({ error: `Forbidden: Missing permission '${permission}'` });
  };
};

// Helper: Get effective permissions for a user (role defaults merged with overrides)
export const getEffectivePermissions = (role: string, overrides: Record<string, boolean> = {}): Record<string, boolean> => {
  const rolePerms = ROLE_PERMISSIONS[role] || {};
  return { ...rolePerms, ...overrides };
};

// Generates a JWT token for a user and a specific tenant context
export const generateToken = (user: any, tenant_id: number, role: string, permissions: Record<string, boolean> = {}) => {
  return jwt.sign(
    {
      id: user.id,
      email: user.email,
      name: user.name || '',
      is_system_admin: user.is_system_admin,
      tenant_id,
      role,
      permissions
    },
    JWT_SECRET,
    { expiresIn: '24h' }
  );
};
