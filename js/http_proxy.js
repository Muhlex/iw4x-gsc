const http = require('http');
const https = require('https');
const url = require('url');

const PORT = 28950;
const HOST = '127.0.0.1';

const server = http.createServer(async (request, response) => {
	try {
		const { pathname, query } = url.parse(request.url, true);

		if (pathname.startsWith('/iw4x-proxy')) {

			/**
			 * Don't necessarily return sensible HTTP responses and status codes.
			 * IW4X only reads responses when they're 2xx status. Our GSC reads
			 * proxied status codes from the body.
			 *
			 * Idea: Always return 200 OK.
			 * First 3 digits of body: Target server status code or 000 for proxy-side error.
			 * Rest of body: Target server body or proxy-side error message.
			 */

			response.writeHead(200); // always return OK, then use body to provide actual status

			if (!['method', 'url'].every(key => key in query)) {
				response.end('000Malformed request: Missing parameters.');
				return;
			}

			const url = new URL(query.url);
			const client = url.protocol === 'https:' ? https : http;
			const headers = Object.fromEntries(
				Object.entries(query)
					.filter(([key]) => key.startsWith('headers[') && key.endsWith(']'))
					.map(([key, value]) => [key.slice('headers['.length, -']'.length), value])
			);

			try {
				const req = client.request(url, {
					method: query.method,
					headers: headers
				}, proxiedRes => {
					response.write(String(proxiedRes.statusCode));
					proxiedRes.on('data', chunk => response.write(chunk));
					proxiedRes.on('end', () => response.end());
				})

				req.on('error', error => {
					response.end('000Target server error:' + error.message);
				});

				if (query.body) req.write(query.body);
				req.end();
			} catch (error) {
				response.end('000Malformed request: ' + error.message);
			}
		}
	} catch (err) {
		console.error(err);
	}
});

server.listen(PORT, HOST, () => console.log('\x1b[32m%s\x1b[0m', `Server is running at: http://${HOST}:${PORT}`));
