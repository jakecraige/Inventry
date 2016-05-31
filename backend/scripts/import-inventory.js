"use strict";

var path = require("path");
var readFileSync = require("fs").readFileSync
var parseSync = require("csv-parse/lib/sync");
var firebase = require("firebase");

//////////////////////////////////////////////////////////////
// CONFIGURATION ////////////////////////////////////////////
///////////////////////////////////////////////////////////////

var CSV_PATH = path.resolve(__dirname, "../../private/inventory.csv");
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

// Filter records with no name or full isbn, all have partial ISBN but barcode
// scanning won't work with the partial so we need to eliminate those
records = records.filter(function(record) {
  return record.Title && record.FullISBN;
});

records = records.map(function(record) {
  return {
    name: record.Title,
    barcode: record.FullISBN.replace(/[^0-9]/g, ""),
    quantity: Number(record.Qty),
    price: Math.floor(Number(record.Price) * 100), // To cents
    currency: "USD",
    imported: true,
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
var importRef = db.ref(FIREBASE_REF_NAME);
var imports = records.map(function(record) {
  return importRef.push().set(record);
});

Promise.all(imports).then(function() {
  console.log("All done!");
  console.log(records.length + " imported.");
  process.exit(0);
}, function(err) {
  console.log("Error!");
  console.log(err);
  process.exit(1);
});

