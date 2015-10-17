var os = require('os');
var https = require('https');
var port = 443;
var bindip = "127.0.0.3";
var fs = require('fs');

var options = {
  key: fs.readFileSync('/etc/pki/tls/private/helloworldkey.pem'),
  cert: fs.readFileSync('/etc/pki/tls/certs/helloworldpublic.pem')
};

https.createServer(options,function (request, response) {
  response.writeHead(200, {'Content-Type': 'text/plain'});
  response.end( 'Hello World from ' + os.hostname() + '!\n' );
}).listen(port);

console.log('Server running at https://' + bindip + ':' + port + '/');

// Redirect from http port 80 to https

var http = require('http');

http.createServer(function (request, response) {
    response.writeHead(301, { "Location": "https://" + request.headers.host + request.url });
    response.end();
}).listen(80);

