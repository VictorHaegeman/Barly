const Joi = require('joi');

const validate = (schema) => (req, res, next) => {
  const payload = { body: req.body, query: req.query, params: req.params };
  const { error, value } = schema.validate(payload, { abortEarly: false, allowUnknown: true });
  if (error) {
    return res.status(400).json({ message: 'Données invalides', details: error.details.map((d) => d.message) });
  }
  req.body = value.body;
  req.query = value.query;
  req.params = value.params;
  return next();
};

const schemas = {
  register: Joi.object({
    body: Joi.object({
      firstName: Joi.string().min(2).required(),
      email: Joi.string().email().required(),
      password: Joi.string().min(6).required(),
      preferences: Joi.object({
        ambiance: Joi.array().items(Joi.string()).default([]),
        music: Joi.array().items(Joi.string()).default([]),
        drinks: Joi.array().items(Joi.string()).default([]),
      }).default({}),
    }),
  }),
  login: Joi.object({
    body: Joi.object({
      email: Joi.string().email().required(),
      password: Joi.string().min(6).required(),
    }),
  }),
  createEvent: Joi.object({
    body: Joi.object({
      barId: Joi.string().required(),
      title: Joi.string().min(2).required(),
      date: Joi.alternatives().try(Joi.date(), Joi.string()).required(),
    }),
  }),
};

module.exports = { validate, schemas };
