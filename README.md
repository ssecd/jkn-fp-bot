# JKN Fingerprint Bot

Solusi untuk mesin APM (Anjungan Pendaftaran Mandiri) yang berbasis web agar dapat membuka aplikasi sidik jadi BPJS Kesehatan melalui browser.

https://github.com/ssecd/jkn-fp-bot/assets/25121822/a73610d6-95d6-4726-bb37-b639984b76f2

## Instalasi

Sebelum memulai instalasi, buka **Windows Powershell** lalu jalankan perintah berikut:

```ps1
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force;
```

Tujuannya untuk mengubah ExecutionPolicy supaya dapat menjalankan script instalasi.

Clone repository ini atau download [Zip](https://github.com/mustofa-id/jkn-fp-bot/archive/refs/heads/main.zip) secara manual jika Git belum terpasang. Setelah clone atau download/extract Zip, klik kanan script `install.ps1` lalu pilih `Run with PowerShell`, jika terdapat prompt terkait Execution Policy, ketik huruf `A` yakni `Yes to All` lalu tunggu hingga proses instalasi selesai. Jika instalasi berhasil, server bot akan berjalan di port 3000 secara default dan seharusnya dapat di-akses melalui browser di alamat http://localhost:3000.

## Penggunaan

Menggunakan `fetch` JavaScript

```js
async function openFingerprint() {
	const response = await fetch(`http://localhost:3000`, {
		method: 'POST',
		body: new URLSearchParams({
			username: 'username-fp',
			password: 'password-fp',
			card_number: 'no-kartu-bpjs',
			exit: true, // wait window for exit (optional, default false)
			wait: 2_000 // wait for login to completed (optional, default 3_593)
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

## Konfigurasi

Konfigurasi tersimpan pada file `.env`, beberapa konfigurasi tersedia diantaranya:

- `SERVER_PORT` Port server default-nya `3000`
- `FP_WIN_TITLE` Windows title aplikasi sidik jari BPJS default-nya `Aplikasi Registrasi Sidik Jari`
- `FP_INS_PATH` Lokasi instalasi aplikasi sidik jari BPJS default-nya `C:\\Program Files (x86)\\BPJS Kesehatan\\Aplikasi Sidik Jari BPJS Kesehatan\\After.exe`

Template file konfigurasi dapat di salin dari file [.env.example](./.env.example)

## Lisensi

[MIT](./LICENSE)

## Lainnya

- [Pemecahan Masalah](https://github.com/mustofa-id/jkn-fp-bot/issues?q=is%3Aissue)
- [Laporkan Bug](https://github.com/mustofa-id/jkn-fp-bot/issues/new)
