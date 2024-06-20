# JKN Fingerprint Bot

Solusi untuk mesin APM (Anjungan Pendaftaran Mandiri) yang berbasis web agar dapat membuka aplikasi sidik jadi BPJS Kesehatan melalui browser.

## Instalasi

Clone repository ini atau download [Zip](https://github.com/mustofa-id/jkn-fp-bot/archive/refs/heads/main.zip) secara manual jika Git belum terpasang. Setelah clone atau download/extract Zip, klik kanan script `install.ps1` lalu pilih `Run with PowerShell` dan tunggu hingga proses instalasi selesai. Jika instalasi berhasil, server bot akan berjalan di port 3000 secara default dan seharusnya dapat di-akses melalui browser di alamat http://localhost:3000.

## Penggunaan

Menggunakan `fetch` JavaScript

```js
async function openFingerprint() {
	const response = await fetch(`http://localhost:3000`, {
		method: 'POST',
		body: new URLSearchParams({
			username: 'username-fp',
			password: 'password-fp',
			card_number: 'no-kartu-bpjs'
		})
	});

	if (response.ok) {
		// Response OK setelah jendela aplikasi sidik jari ditutup
	} else {
		const result = await response.json();
		alert(result.message);
	}
}
```

## Lisensi

[MIT](./LICENSE)

## Lainnya

- [Pemecahan Masalah](https://github.com/mustofa-id/jkn-fp-bot/issues?q=is%3Aissue)
- [Laporkan Bug](https://github.com/mustofa-id/jkn-fp-bot/issues/new)
