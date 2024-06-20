# JKN Fingerprint Bot

Solusi untuk mesin APM (Anjungan Pendaftaran Mandiri) yang berbasis web agar dapat membuka aplikasi sidik jadi BPJS Kesehatan melalui browser.

## Instalasi

Clone repository ini atau download [Zip](/archive/refs/heads/main.zip) secara manual jika Git belum terpasang. Setelah clone atau download/extract Zip, klik kanan script `install.ps1` lalu pilih `Run with PowerShell` dan tunggu hingga proses instalasi selesai. Jika instalasi berhasil, server bot akan berjalan di port 3000 secara default dan seharusnya dapat di-akses melalui browser di alamat http://localhost:3000.

## Penggunaan

Menggunakan `fetch` JavaScript

```js
async function openFingerprint() {
	const fd = new FormData();
	fd.set('username', 'username_fp');
	fd.set('password', 'password_fp');
	fd.set('card_number', 'no_kartu_bpjs');

	const response = await fetch(`http://localhost:3000`, {
		method: 'POST',
		body: fd
	});

	if (response.ok) {
		// checkFpStatus
	} else {
		const result = await response.json();
		alert(result.message);
	}
}
```

atau menggunakan `<form />`

```html
<form action="http://localhost:3000" method="post">
	<input name="username" value="username_fp" hidden />
	<input name="password" value="password_fp" hidden />
	<input name="card_number" value="no_kartu_bpjs" hidden />
	<button type="submit">Buka Fingerprint</button>
</form>
```

## Lisensi

[MIT](./LICENSE)

## Lainnya

- [Pemecahan Masalah](/issues?q=is%3Aissue)
- [Laporkan Bug](/issues/new)
