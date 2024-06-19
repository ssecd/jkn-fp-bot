// @ts-check
import bot from 'node-autoit-koffi';
import { createServer } from 'node:http';
import qs from 'node:querystring';
import pkg from './package.json' assert { type: 'json' };

const host = `http://localhost`;
const port = process.env.SERVER_PORT || 3000;
const fp_win_title = process.env.FP_WIN_TITLE || 'Aplikasi Registrasi Sidik Jari';
const fp_ins_path = process.env.FP_INS_PATH || 'C:\\Program Files (x86)\\BPJS Kesehatan\\Aplikasi Sidik Jari BPJS Kesehatan\\After.exe';

const server = createServer((req, res) => {
	/** @param {Error} error  */
	function handle_error(error) {
		console.error(error);
		json(500, { message: error?.message || `Internal server error` });
	}

	/**
	 * @param {number} status
	 * @param {any =} data
	 */
	function json(status, data) {
		res.writeHead(status, { 'Content-Type': 'application/json' });
		if (!data) return res.end();
		res.end(JSON.stringify(data));
	}

	try {
		const url = new URL(req.url || '/', host);
		if (url.pathname === '/' && req.method === 'GET') {
			// service info
			json(200, {
				message: `Name: ${pkg.name} \nDescription: ${pkg.description} \nVersion: ${pkg.version}`
			});
		} else if (url.pathname === '/' && req.method === 'POST') {
			// apm bot service
			let body = '';
			req.on('data', (chunk) => (body += chunk.toString()));
			req.on('end', () => {
				const form_data = qs.parse(body);
				const username = form_data['username'];
				const password = form_data['password'];
				const card_number = form_data['card_number'];

				if (!username || !password || !card_number) {
					return json(400, {
						message: `username, password, and card_number are required fields`
					});
				}

				run_bot({ username, password, card_number })
					.then(() => json(201))
					.catch((e) => handle_error(e));
			});
		} else {
			json(404, { message: `Not found` });
		}
	} catch (error) {
		handle_error(error);
	}
});

server.on('error', (err) => {
	// might to try restarting the server or take other actions
	console.error('Server error:', err);
});

server.listen(port, () => {
	console.log(`Server running at ${host}:${port}`);
});

/** @param {number} ms */
async function sleep(ms) {
	await new Promise((resolve) => setTimeout(resolve, ms));
}

async function run_bot({ username, password, card_number }) {
	// open or activate the application window
	if (!(await bot.winExists(fp_win_title))) {
		await bot.run(fp_ins_path);
		await bot.winWait(fp_win_title); // wait for the application window to appear
	}

	await bot.winActivate(fp_win_title); // activate the application window
	await bot.winWaitActive(fp_win_title); // wait for the application to be in focus
	await bot.winSetOnTop(fp_win_title, '', 1); // set window on top

	// get the position and size of the window
	const win_pos = await bot.winGetPos(fp_win_title);

	if (!win_pos) {
		console.error('Failed to get window position');
		return;
	}

	const { top, left } = win_pos;

	// move the mouse cursor to the calculated absolute position
	const x = left + 223;
	const y = top + 179;
	await bot.mouseMove(x, y, 0);
	await bot.mouseClick('left');

	await sleep(500);

	// clear and enter the username
	await bot.send('^a');
	await bot.send('{BACKSPACE}');
	await bot.send(username);

	await bot.send('{TAB}');

	// clear and enter the password
	await bot.send('^a');
	await bot.send('{BACKSPACE}');
	await bot.send(password);

	await bot.send('{ENTER}');
}
