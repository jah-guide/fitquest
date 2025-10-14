// JWT verification middleware. Adds req.user = { id, email } when token valid
const jwt = require('jsonwebtoken');

module.exports = function (req, res, next) {
  const authHeader = req.header('Authorization');
  if (!authHeader) return res.status(401).json({ msg: 'No token, authorization denied' });

  // Expect header as: "Bearer <token>"
  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return res.status(401).json({ msg: 'Malformed authorization header' });
  }

  const token = parts[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = { id: decoded.id, email: decoded.email };
    next();
  } catch (err) {
    return res.status(401).json({ msg: 'Token is not valid' });
  }
};
