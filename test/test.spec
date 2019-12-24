{
  "$id": "https://eliud.io/schemas/test.json",
  "description": "A representation of a person, company, organization, or place",
  "type": "object",
  "properties": {
    "ID": {
      "type": "string"
    },
    "menuItems": {
      "type": "array",
      "items": { "$ref": "#/definitions/menuItem" }
    }
  },
  "definitions": {
    "menuItem": {
      "type": "object",
	  "required": [ "text", "description", "icon", "action" ],
      "properties": {
          "text": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "icon": {
            "type": "string"
          },
          "action": {
            "$ref": "file:///test.spec#/definitions/menuItem"
          }
      }
    }
  }
}