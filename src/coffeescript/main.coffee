fs = require("fs")

fs.readFileSync('./input.txt').toString().split('\n').forEach(function (line) { 
    console.log(line);
    fs.appendFileSync("./output.txt", line.toString() + "\n");
});