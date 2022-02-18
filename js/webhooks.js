const http = require('http');
const https = require('https');
const url = require('url');

const PORT = 28950;
const HOST = '127.0.0.1';

const server = http.createServer(async (request, response) => {
	try {
		const { pathname, query } = url.parse(request.url, true);

		if (pathname.startsWith('/webhook')) {
			if (!query.url || !query.body) {
				response.writeHead(400);
				response.end('Malformed request.');
				return;
			}

			const req = https.request(query.url, {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' }
			}, res => {
				response.writeHead(res.statusCode);
				res.on('data', chunk => response.write(chunk));
				res.on('end', () => response.end());
			})

			req.on('error', e => {
				response.writeHead(400);
				response.end(`Webhook could not be sent:\n${e.message}`);
			});

			query.body = query.body.replaceAll('%CURRENTTIME%', new Date().toISOString());

			req.write(query.body);
			req.end();
		}
	} catch (err) {
		console.error(err);
	}
});

server.listen(PORT, HOST, () => console.log('\x1b[32m%s\x1b[0m', `Server is running at http://${HOST}:${PORT}`));
