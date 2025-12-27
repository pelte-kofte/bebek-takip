class Dil {
  // Genel
  static const String appName = 'Bebek Takip';
  static const String kaydet = 'Kaydet';
  static const String guncelle = 'Güncelle';
  static const String iptal = 'İptal';
  static const String sil = 'Sil';
  static const String duzenle = 'Düzenle';
  static const String tamam = 'Tamam';
  static const String ekle = 'Ekle';
  static const String dakika = 'dakika';
  static const String dk = 'dk';
  static const String saat = 'saat';
  static const String sa = 'sa';
  
  // Ana Sayfa
  static const String anaSayfa = 'Ana Sayfa';
  static const String sonAktiviteler = 'Son Aktiviteler';
  static const String bugun = 'Bugün';
  static const String zaman = 'Zaman Çizelgesi';
  static const String son24Saat = 'Son 24 saat';
  static const String buyumeTakibi = 'Büyüme Takibi';
  static const String henuzKayitYok = 'Henüz kayıt yok';
  static const String henuzOlcumYok = 'Henüz ölçüm yok';
  
  // Beslenme
  static const String beslenme = 'Beslenme';
  static const String beslenmeEkle = 'Beslenme Ekle';
  static const String beslenmeDuzenle = 'Beslenme Düzenle';
  static const String emzirme = 'Emzirme';
  static const String anneSutu = 'Anne Sütü';
  static const String formula = 'Formül';
  static const String biberonAnneSutu = 'Biberonla Anne Sütü';
  static const String biberon = 'Biberon';
  static const String solMeme = 'Sol Meme';
  static const String sagMeme = 'Sağ Meme';
  static const String toplam = 'Toplam';
  static const String sonBeslenme = 'Son Beslenme';
  
  // Bez
  static const String bez = 'Bez';
  static const String bezDegisimi = 'Bez Değişimi';
  static const String bezEkle = 'Bez Ekle';
  static const String islak = 'Islak';
  static const String kirli = 'Kirli';
  static const String ikisiBirden = 'İkisi Birden';
  static const String sonBezDegisimi = 'Son Bez';
  
  // Uyku
  static const String uyku = 'Uyku';
  static const String uykuEkle = 'Uyku Ekle';
  static const String uykuDuzenle = 'Uyku Düzenle';
  static const String baslangic = 'Başlangıç';
  static const String bitis = 'Bitiş';
  static const String sure = 'Süre';
  static const String uyanik = 'Uyanık';
  static const String sonUyku = 'Son Uyku';
  
  // Anı
  static const String ani = 'Anı';
  static const String anilar = 'Anılar';
  static const String aniEkle = 'Anı Ekle';
  static const String aniDuzenle = 'Anı Düzenle';
  static const String baslik = 'Başlık';
  static const String not = 'Not';
  
  // Ölçüm
  static const String olcum = 'Ölçüm';
  static const String olcumEkle = 'Ölçüm Ekle';
  static const String boy = 'Boy';
  static const String kilo = 'Kilo';
  static const String basCevresi = 'Baş Çevresi';
  static const String opsiyonel = 'opsiyonel';
  static const String tarihSec = 'Tarih Seç';
  
  // Aktiviteler
  static const String aktiviteler = 'Aktiviteler';
  static const String kayitYok = 'Bu tarihte kayıt yok';
  static const String baskaTarihSec = 'Başka tarih seç';
  static const String kayit = 'kayıt';
  
  // Gelişim
  static const String gelisimAsamalari = 'Gelişim Aşamaları';
  static const String ilerleme = 'İlerleme';
  static const String tamamlandi = 'Tamamlandı';
  static const String ayindaBekleniyor = 'ayında bekleniyor';
  
  // Ayarlar
  static const String ayarlar = 'Ayarlar';
  static const String gorunum = 'Görünüm';
  static const String karanlikMod = 'Karanlık Mod';
  static const String karanlikModAciklama = 'Göz yormayan koyu tema';
  static const String bebekBilgileri = 'Bebek Bilgileri';
  static const String bebekAdi = 'Bebek Adı';
  static const String dogumTarihi = 'Doğum Tarihi';
  static const String bildirimler = 'Bildirimler';
  static const String mamaHatirlatici = 'Beslenme Hatırlatıcı';
  static const String bezHatirlatici = 'Bez Hatırlatıcı';
  static const String veriYonetimi = 'Veri Yönetimi';
  static const String verileriDisaAktar = 'Verileri Dışa Aktar';
  static const String tumVerileriSil = 'Tüm Verileri Sil';
  static const String dikkat = 'Dikkat';
  static const String silmeUyarisi = 'Tüm veriler silinecek. Bu işlem geri alınamaz!';
  static const String hakkinda = 'Hakkında';
  static const String versiyon = 'Versiyon';
  static const String gelistirici = 'Geliştirici';
  
  // Navigasyon
  static const String navAnaSayfa = 'Ana Sayfa';
  static const String navAktiviteler = 'Aktiviteler';
  static const String navGelisim = 'Gelişim';
  static const String navAyarlar = 'Ayarlar';
  
  // Zaman
  static const String dakikaOnce = 'dakika önce';
  static const String saatOnce = 'saat önce';
  static const String gunOnce = 'gün önce';
  static const String azOnce = 'az önce';
  
  // Silme onayı
  static const String silmekIstiyor = 'Bu kaydı silmek istediğine emin misin?';
  static const String evet = 'Evet';
  static const String hayir = 'Hayır';
  
  // Ne eklemek istersin
  static const String neEklemekIstersin = 'Ne eklemek istersin?';
  
  // Aylar
  static const List<String> aylar = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık'
  ];
}