"use latest";

import Stripe from 'stripe';

export default function(ctx, cb) {
  const stripe = Stripe(ctx.secrets.STRIPE_API_KEY);
  stripe.charges.create({
    amount: ctx.body.amount,
    currency: ctx.body.currency,
    description: ctx.body.description,
    source: ctx.body.token,
  }).then(charge => {
    cb(null, charge);
  }).catch(cb);
};
