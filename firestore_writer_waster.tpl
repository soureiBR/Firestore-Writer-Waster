___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Firestore Writer Waster",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "Use this tag for writing data to the Firestore.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "CHECKBOX",
    "name": "addEventData",
    "checkboxText": "Add Event Data",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "collection",
    "displayName": "Collection Name",
    "simpleValueType": true,
    "help": "Name of the collection in Firestore. If not specified, it will automatically be set to the container identifier in Waster."
  },
  {
    "type": "TEXT",
    "name": "documentId",
    "displayName": "Document ID",
    "simpleValueType": true,
    "help": "Leave empty to auto-generate",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "apiToken",
    "displayName": "Api Token",
    "simpleValueType": true,
    "help": "Credential required to perform writes and reads in firestore.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "SIMPLE_TABLE",
    "name": "fieldsToSave",
    "displayName": "Fields to Save",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Field Name",
        "name": "fieldName",
        "type": "TEXT"
      },
      {
        "defaultValue": "",
        "displayName": "Value",
        "name": "fieldValue",
        "type": "TEXT"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const fetch = require('sendHttpRequest');
const JSON = require('JSON');
const getAllEventData = require('getAllEventData');
const logToConsole = require('logToConsole');
const getTimestampMillis = require('getTimestampMillis');
const getEventData = require('getEventData');

const collection = data.collection;
const documentId = data.documentId || 'auto-generated-' + getTimestampMillis();

const fields = data.addEventData ? getAllEventData() : {};

const body = {
  data: null,
  documentId: documentId,
  collection: collection
};

if (data.fieldsToSave && data.fieldsToSave.length > 0) {
  data.fieldsToSave.forEach(function(field) {
    if (field.fieldName && field.fieldValue !== undefined) {
      let processedValue = field.fieldValue;
      
      fields[field.fieldName] = processedValue;
    }
  });
}

const currentTimestampMillis = getTimestampMillis();
fields.timestamp = currentTimestampMillis;
fields.event_name = data.event_name_standard;

body.data = fields;

const url = 'https://waster.sourei.com.br/firebase/store';

const response = fetch(url, {
  method: 'PATCH',
  headers: {
    'Content-Type': 'application/json',
    'x-api-token': data.apiToken
  }
}, JSON.stringify(body));

response.then((res) => {
  logToConsole('Status Code:', res.statusCode);
  
  if (res.statusCode >= 200 && res.statusCode < 300) {
    logToConsole('Dados salvos com sucesso no Firestore');
    data.gtmOnSuccess();
  } else {
    logToConsole('Erro ao salvar no Firestore:', res.body);
    data.gtmOnFailure();
  }
}).catch((error) => {
  logToConsole('Erro na requisição:', error);
  data.gtmOnFailure();
});


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 02/06/2025, 21:46:45


