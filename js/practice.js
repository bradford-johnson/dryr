const fs = require("fs");

const mockDataPath = "js/mock_data.json";

try {
  const data = fs.readFileSync(mockDataPath, "utf-8");

  // Parse the JSON string into a JavaScript array of objects
  const jsonData = JSON.parse(data);

  // Assuming you want to iterate through the keys of the first item (index 0)
  const firstItem = jsonData[0];

  // Iterate through the keys of the first item and print them
  for (const key in firstItem) {
    console.log(key);
  }
} catch (err) {
  console.error(err);
}
