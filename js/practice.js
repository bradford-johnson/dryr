const fs = require("fs");

const mockDataPath = "js/mock_data.json";

try {
  const data = fs.readFileSync(mockDataPath, "utf-8");

  const jsonData = JSON.parse(data);

  const firstItem = jsonData[0];

  for (const key in firstItem) {
    console.log(key);
  }
} catch (err) {
  console.error(err);
}
