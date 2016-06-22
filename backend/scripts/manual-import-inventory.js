"use strict";

var path = require("path");
var readFileSync = require("fs").readFileSync
var parseSync = require("csv-parse/lib/sync");
var firebase = require("firebase");

//////////////////////////////////////////////////////////////
// CONFIGURATION ////////////////////////////////////////////
///////////////////////////////////////////////////////////////

var USER_ID = "1234";
var CSV_PATH = path.resolve(__dirname, "../../private/manual-inventory.csv");
var FIREBASE_REF_NAME = "TESTProducts";
var SERVICE_ACCOUNT_PATH = path.resolve(__dirname, "../../private/Inventry-a59707411f79.json");
var DATABASE_URL = "https://inventry-1325.firebaseio.com";

//////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

var app = firebase.initializeApp({
  serviceAccount: SERVICE_ACCOUNT_PATH,
  databaseURL: DATABASE_URL,
});
var db = app.database();

var csvContent = readFileSync(CSV_PATH, 'utf8');
var records = parseSync(csvContent, {columns: true});

records = records.map(function(record) {
  return {
    name: record.name,
    barcode: record.barcode.replace(/[^0-9]/g, ""),
    quantity: Number(record.quantity),
    price: Math.floor(Number(record.price) * 100), // To cents
    currency: "USD",
    user_id: USER_ID,
  };
});

// Merge duplicates
records = records.reduce(function(acc, record) {
  var barcode = record.barcode;
  if (acc[barcode]) {
    acc[barcode].quantity = acc[barcode].quantity + record.quantity
  } else {
    acc[barcode] = record;
  }
  return acc;
}, {});

// Map values
records = Object.keys(records).map(function(key) { return records[key]; })

// Import into firebase
var productsRef = db.ref(FIREBASE_REF_NAME);
var imports = records.map(function(record) {
  var ref = productsRef.push();
  return ref.set(record).then(function() {
    return ref.key
  });
});

Promise.all(imports).then(function(keys) {
  var keyedProducts = keys.reduce(function(res, key) {
    res[key] = true;
    return res;
  }, {});
  var userProductsRef = db.ref("Users/" + USER_ID + "/Products");
  return userProductsRef.set(keyedProducts);
}).then(function() {
  console.log("All done!");
  console.log(records.length + " imported.");
  process.exit(0);
}, function(err) {
  console.log("Error!");
  console.log(err);
  process.exit(1);
});
