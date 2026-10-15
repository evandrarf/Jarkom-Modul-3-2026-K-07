# Kelompok K-07 Laporan Resmi Jarkom Modul 3

## Anggota Kelompok

| Nama                   | NRP        |
| :--------------------- | :--------- |
| Evandra Raditya Fauzan | 5027251001 |
| Keisya Dira Anugerah   | 5027251055 |

## Daftar Isi

1. [Soal 1](#soal-1)
2. [Soal 2](#soal-2)
3. [Soal 3](#soal-3)
4. [Soal 4](#soal-4)
5. [Soal 5](#soal-5)
6. [Soal 6](#soal-6)
7. [Soal 7](#soal-7)
8. [Soal 8](#soal-8)
9. [Soal 9](#soal-9)
10. [Soal 10](#soal-10)
11. [Konfigurasi DNS Master dan Slave](#11-konfigurasi-dns-master-dan-slave)
12. [Konfigurasi Record DNS dan Forwarder](#12-konfigurasi-record-dns-dan-forwarder)
13. [Replikasi Basis Data](#13-replikasi-basis-data)
14. [Konfigurasi Worker Web dan API](#14-konfigurasi-worker-web-dan-api)
15. [Konfigurasi Load Balancer Internal](#15-konfigurasi-load-balancer-internal)
16. [Konfigurasi Reverse Proxy Publik](#16-konfigurasi-reverse-proxy-publik)
17. [Penerusan Alamat IP Klien](#17-penerusan-alamat-ip-klien)
18. [Worker Cadangan dan Health Check](#18-worker-cadangan-dan-health-check)
19. [Proxy Caching dan Rate Limiting](#19-proxy-caching-dan-rate-limiting)
20. [Pengujian Kinerja dengan Apache Benchmark](#20-pengujian-kinerja-dengan-apache-benchmark)

---

## Laporan Resmi

### 1. Topologi Jaringan

### 2. Soal 2

### 3. Soal 3

### 4. Soal 4

### 5. Soal 5

### 6. Soal 6

### 7. Soal 7

### 8. Soal 8

### 9. Soal 9

### 10. Soal 10

---

### 11. Konfigurasi DNS Master dan Slave

#### Soal
Utahime dan Shoko ditugaskan membangun sistem penamaan domain resmi agar seluruh pos tidak perlu menghafal alamat IP mentah. Konfigurasikan BIND9 pada utahime sebagai DNS Master dan shoko sebagai DNS Slave untuk mengelola domain `jujutsu.k07.com`. Atur SOA record, NS delegasi untuk kedua server, dan terapkan allow-transfer dari Master ke Slave. Pastikan file zona berhasil tersinkronisasi otomatis ke shoko saat nomor serial di utahime dinaikkan, lalu buktikan dengan melakukan query dig ke kedua server dari salah satu client.

#### Penjelasan & Konfigurasi
Zona `jujutsu.k07.com` dibangun di utahime sebagai master, artinya utahime menjadi sumber data utama yang dianggap paling benar. Di dalam zona, SOA menunjuk ke `ns1.jujutsu.k07.com` sebagai server utama dan memuat nomor serial. Serial inilah yang dibandingkan shoko untuk memutuskan apakah ia perlu menarik data baru. Dua NS (ns1 dan ns2) menyatakan bahwa zona ini dilayani oleh utahime dan shoko, masing-masing dengan A record agar nama NS bisa di-resolve ke IP `10.67.1.2` dan `10.67.1.3.`


**Konfigurasi Utahime**

```bash
cat > /root/11.sh << 'EOF'
#!/bin/bash
# 11.sh (utahime) - DNS Master jujutsu.k07.com

echo "nameserver 192.168.122.1" > /etc/resolv.conf

if ! command -v named >/dev/null 2>&1; then
    apt-get update
    apt-get install -y bind9 bind9utils dnsutils
fi

mkdir -p /etc/bind/jujutsu
cat > /etc/bind/named.conf.options << 'EOT'
options {
    directory "/var/cache/bind";
    listen-on { any; };
    allow-query { any; };
    recursion yes;
    allow-recursion { 10.67.0.0/16; 127.0.0.1; };
    dnssec-validation no;
};
EOT

cat > /etc/bind/named.conf.local << 'EOT'
zone "jujutsu.k07.com" {
    type master;
    file "/etc/bind/jujutsu/db.jujutsu.k07.com";
    notify yes;
    allow-transfer { 10.67.1.3; };
    also-notify { 10.67.1.3; };
};
EOT

cat > /etc/bind/jujutsu/db.jujutsu.k07.com << 'EOT'
$TTL 604800
@   IN  SOA ns1.jujutsu.k07.com. admin.jujutsu.k07.com. (
            2026101402  ; serial #diubah antara 01 02
            604800      ; refresh
            86400       ; retry
            2419200     ; expire
            604800 )    ; negative cache
@   IN  NS  ns1.jujutsu.k07.com.
@   IN  NS  ns2.jujutsu.k07.com.
ns1 IN  A   10.67.1.2
ns2 IN  A   10.67.1.3
EOT
```
Opsi allow-transfer dibatasi hanya untuk IP shoko (10.67.1.3), supaya salinan seluruh isi zona tidak bisa diminta oleh sembarang host. Opsi notify dan also-notify membuat utahime aktif memberi tahu shoko begitu zona berubah, sehingga sinkronisasi tidak menunggu interval refresh. Pada named.conf.options, allow-recursion dibatasi ke jaringan internal agar utahime tidak menjadi open resolver.

**Konfigurasi Shoko**

Konfigurasi shoko sebagai slave mirip dengan master, hanya berbeda pada tipe zona dan file zona yang digunakan. Shoko akan menarik data dari utahime saat serial master lebih tinggi.

```bash
cat > /etc/bind/named.conf.local << 'EOT'
zone "jujutsu.k07.com" {
    type slave;
    masters { 10.67.1.2; };
    file "/var/cache/bind/slaves/db.jujutsu.k07.com";
};
EOT
```

#### Hasil Pengujian
Setelah konfigurasi selesai, dapat dilakukan pengujian dari perintah

```bash
# uji master
service named status
dig @127.0.0.1 jujutsu.k07.com SOA +short
```
```bash
#uji client
dig @10.67.1.2 jujutsu.k07.com SOA +short
dig @10.67.1.3 jujutsu.k07.com SOA +short
```


---

### 12. Konfigurasi Record DNS dan Forwarder

#### Soal
Peta domain harus memetakan pintu masuk utama dan tetap bisa mencari alamat di luar kawasan Shibuya. Pada utahime, buat A record `jujutsu.k07.com` yang mengarah ke gojo, serta CNAME `www` yang merujuk ke domain utama tersebut. Buat pula Reverse DNS (zona PTR) untuk melacak IP gojo kembali ke domain resminya, dan aktifkan fitur DNS Forwarder pada BIND9 mengarah ke IP gateway internet (192.168.122.1). Uji dari client dengan dig untuk mengecek CNAME, PTR, dan buktikan client tetap bisa melakukan ping ke domain internet seperti `google.com.`

#### Penjelasan & Konfigurasi

Pada `utahime`, zona forward ditambah A record `jujutsu` yang menunjuk ke IP `gojo` dan CNAME `www` yang merujuk ke `jujutsu.k07.com`. Zona reverse untuk Network 1 ditambahkan beserta PTR yang melacak IP `gojo` kembali ke domain resminya. Fitur forwarder diaktifkan pada `named.conf.options` dengan tujuan `192.168.122.1`, sehingga domain di luar zona (misalnya `google.com`) tetap bisa di-resolve. Seluruh perubahan disimpan di `12.sh`, dan serial zona dinaikkan agar shoko ikut menyinkronkan record baru.

```bash
cat > /root/12.sh << 'EOF'
#!/bin/bash
# 12.sh (utahime) - A, CNAME, PTR, forwarder

echo "nameserver 192.168.122.1" > /etc/resolv.conf

if ! command -v named >/dev/null 2>&1; then
    apt-get update
    apt-get install -y bind9 bind9utils dnsutils
fi

mkdir -p /etc/bind/jujutsu

cat > /etc/bind/named.conf.options << 'EOT'
options {
    directory "/var/cache/bind";
    listen-on { any; };
    allow-query { any; };
    recursion yes;
    allow-recursion { 10.67.0.0/16; 127.0.0.1; };
    forwarders { 192.168.122.1; };
    forward only;
    dnssec-validation no;
};
EOT

cat > /etc/bind/named.conf.local << 'EOT'
zone "jujutsu.k07.com" {
    type master;
    file "/etc/bind/jujutsu/db.jujutsu.k07.com";
    notify yes;
    allow-transfer { 10.67.1.3; };
    also-notify { 10.67.1.3; };
};

zone "1.67.10.in-addr.arpa" {
    type master;
    file "/etc/bind/jujutsu/db.10.67.1";
};
EOT

cat > /etc/bind/jujutsu/db.jujutsu.k07.com << 'EOT'
$TTL 604800
@   IN  SOA ns1.jujutsu.k07.com. admin.jujutsu.k07.com. (
            2026101403  ; serial
            604800      ; refresh
            86400       ; retry
            2419200     ; expire
            604800 )    ; negative cache
@   IN  NS  ns1.jujutsu.k07.com.
@   IN  NS  ns2.jujutsu.k07.com.
ns1 IN  A   10.67.1.2
ns2 IN  A   10.67.1.3
@   IN  A   10.67.1.4
www IN  CNAME jujutsu.k07.com.
EOT

cat > /etc/bind/jujutsu/db.10.67.1 << 'EOT'
$TTL 604800
@   IN  SOA ns1.jujutsu.k07.com. admin.jujutsu.k07.com. (
            2026101401  ; serial
            604800
            86400
            2419200
            604800 )
@   IN  NS  ns1.jujutsu.k07.com.
@   IN  NS  ns2.jujutsu.k07.com.
4   IN  PTR jujutsu.k07.com.
EOT

chown -R bind:bind /etc/bind/jujutsu 2>/dev/null

named-checkconf \
  && named-checkzone jujutsu.k07.com /etc/bind/jujutsu/db.jujutsu.k07.com \
  && named-checkzone 1.67.10.in-addr.arpa /etc/bind/jujutsu/db.10.67.1 \
  && (service named restart || service bind9 restart)
EOF
```

#### Hasil Pengujian

---

### 13. Replikasi Basis Data

#### Soal
Kepala Sekolah Yaga dan Inumaki mendirikan database terpusat yang redundan agar log aktivitas kutukan tetap aman tersimpan. Konfigurasikan MariaDB pada yaga sebagai DB-Master dan inumaki sebagai DB-Slave. Buat database `db_shibuya_k07` beserta tabel `request_logs` di Master, aktifkan binary logging (log-bin, server-id), lalu hubungkan inumaki sebagai Slave yang menyalin data secara realtime dengan `CHANGE MASTER TO.` Berikan hak akses remote bagi seluruh node di Network 4, lalu buktikan replikasi berhasil dengan memasukkan data baru di Master dan memeriksa hasilnya di Slave.


---

### 14. Konfigurasi Worker Web dan API

#### Soal
Para penyihir lapangan bersiaga di Data Center sebagai pekerja backend untuk memproses aplikasi. Pasang `Nginx` dan `PHP-FPM` pada maki dan panda untuk menyajikan web frontend yang menampilkan hostname masing-masing. Pada nanami, todo, dan kirara, siapkan layanan API yang mencatat log request ke database yaga. Konfigurasikan virtual host agar worker merespons domain layanan yang ditentukan. Batasi akses langsung dari klien ke worker, web worker hanya menerima trafik melalui jalur proxy web yang ditentukan, sedangkan worker API hanya menerima trafik melalui geto. Uji bahwa akses langsung dari klien ditolak, sementara akses melalui reverse proxy tetap berhasil.



---

### 15. Konfigurasi Load Balancer Internal

#### Soal
Geto bertugas mengendalikan pembagian beban request API di internal Data Center agar server tidak tumbang bersamaan. Konfigurasikan Nginx pada geto sebagai Load Balancer internal dengan `upstream api_cluster` yang mengarahkan trafik ke nanami dan todo. Terapkan algoritma Weighted Round Robin dengan bobot 3:1, di mana nanami menerima porsi beban tiga kali lebih banyak daripada todo. Buktikan distribusi beban ini dengan melakukan loop request berulang kali ke geto dari jaringan lokal Data Center dan periksa rasio responnya.


---

### 16. Konfigurasi Reverse Proxy Publik

#### Soal
Gojo berdiri di perbatasan DMZ sebagai gerbang publik tunggal bagi seluruh client dari luar maupun dalam. Konfigurasikan Nginx pada gojo untuk melayani domain `jujutsu.<xxxx>.com` dan`www.jujutsu.<xxxx>`.com menggunakan metode Path-Based Routing. Atur agar request root (/) diteruskan secara Round Robin ke worker frontend (maki dan panda), sedangkan request ke path /api diteruskan langsung ke geto. Uji dari client Divisi A atau B bahwa akses ke web utama dibalas oleh Maki/Panda, sedangkan akses ke /api diteruskan dan dijawab oleh Nanami/Todo.

---

### 17. Penerusan Alamat IP Klien
#### Soal
Komando pusat perlu mengetahui IP asli klien yang mengirimkan request tanpa tertukar dengan IP proxy perantara. Konfigurasikan gojo dan geto agar meneruskan informasi alamat klien melalui header `X-Real-IP` dan `X-Forwarded-For`. Pastikan geto hanya mempercayai informasi alamat klien yang diterima dari proxy terpercaya, dan skrip API menyimpan alamat klien yang telah diverifikasi ke kolom `client_ip` pada tabel `request_logs` di database yaga. Uji dengan mengirimkan request dari klien Network 2 dan Network 3 ke endpoint /api, kemudian periksa database untuk memastikan alamat yang tercatat sesuai dengan IP klien asal, bukan IP gojo atau geto.

---

### 18. Worker Cadangan dan Health Check
#### Soal
​Nanami dan Todo merupakan worker API utama, sedangkan kirara disiapkan sebagai worker cadangan. Konfigurasikan upstream `api_cluster` pada geto agar kirara menjadi server backup, serta terapkan passive health check dengan parameter `max_fails=2` dan `fail_timeout=5s` pada worker API utama. Pastikan kirara menjalankan layanan API yang kompatibel dengan endpoint utama. Simulasikan gangguan dengan menghentikan layanan Nginx atau layanan API pada nanami dan todo. Buktikan dari klien bahwa request ke /api dialihkan ke kirara dan menghasilkan respons API yang valid tanpa error `502 Bad Gateway.`

---

### 19. Proxy Caching dan Rate Limiting
#### Soal
Gojo bertugas mengoptimalkan layanan web sekaligus membatasi request berlebihan. Konfigurasikan Nginx Proxy Caching untuk halaman web frontend dengan masa berlaku cache 10 menit dan tambahkan header `X-Cache-Status`. Terapkan rate limiting pada path /api dengan batas 10 request per detik per IP klien. Buktikan bahwa request ke halaman web yang memenuhi syarat cache menghasilkan status MISS pada akses awal dan HIT pada akses berikutnya. Uji rate limiting secara terpisah dengan mengirimkan request beruntun ke /api, kemudian catat status respons yang dihasilkan ketika batas terlampaui.

---

### 20. Pengujian Kinerja dengan Apache Benchmark
#### Soal
Sebelum Curtain di Shibuya resmi dibuka, Kusakabe memimpin audit untuk menguji kapasitas layanan. Dari terminal kusakabe, jalankan benchmark menggunakan Apache Benchmark dengan parameter `-n 600 -c 30` menuju `http://jujutsu.<xxxx>.com/`. Catat Requests per Second (RPS), latensi, dan jumlah request yang gagal. Lakukan pengujian tambahan pada endpoint /api untuk mengamati efek rate limiting. Bandingkan hasil pengujian baseline dengan hasil ketika rate limiting aktif, serta gunakan access log gojo untuk membedakan kegagalan aplikasi, koneksi, dan request yang ditolak oleh kebijakan rate limit.