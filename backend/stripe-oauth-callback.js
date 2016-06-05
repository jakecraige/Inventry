"use latest";

import request from "request";

const TOKEN_URI = "https://connect.stripe.com/oauth/token";

export default function(ctx, cb) {
  request.post({
    url: TOKEN_URI,
    form: {
      grant_type: "authorization_code",
      client_id: ctx.secrets.CLIENT_ID,
      code: ctx.query.code,
      client_secret: ctx.secrets.API_KEY
    }
  }, function(err, r, body) {
    if (err) {
      return cb(err);
    }

    const accessToken = JSON.parse(body).access_token;

    cb(null, {accessToken});
  });
};
