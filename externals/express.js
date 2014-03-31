var express = require('express');
var app = express();
var path = require('path');

app.use(express.bodyParser({
  uploadDir: path.resolve(__dirname, '../upload')
}));

app.get('/', function(req, res) {
  res.sendfile(path.resolve('demo.html'));
});
module.exports = app;

var fs = require('fs');
app.post('/upload', function(req, res) {
	var tmp_path = req.files.upload_file.path;
	var target_path = path.resolve(__dirname, '../upload/', req.files.upload_file.name);
	fs.rename(tmp_path, target_path, function(err) {
		if (err) throw err;
		fs.unlink(tmp_path, function() {
			if (err) throw err;
			res.send({ file_path: '/upload/' + req.files.upload_file.name });
		});
	});
});
