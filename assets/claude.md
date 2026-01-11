# Bebek Takip Uygulaması – Claude Rehberi

## Proje
- Flutter ile geliştirilmiş mobile uygulama
- iOS / Android öncelikli
- Web sadece development ve test amaçlı

## Kapsam
- React Native yok
- Push notification yok (özellikle istenmedikçe)
- Cloud sync yok (local persistence kullanılıyor)

## Mimari
- TimerYonetici ve VeriYonetici singleton yapıları korunacak
- Timer, persistence ve state yönetimine dokunma
- Mevcut logic bozulmayacak

## Tasarım
- "Vurucu ama sade" tasarım dili
- Home ekranı daha güçlü ve duygusal
- Diğer ekranlar daha soft ama tutarlı
- Ortak font, renk ve spacing sistemi kullanılacak

## Kod Kuralları
- Sadece belirtilen dosyalarda değişiklik yap
- Küçük ve kontrollü değişiklikler yap
- Büyük refactor önerme
- Widget tree parantezlerine dikkat et
- Syntax hatası bırakma

## İletişim
- Gereksiz analiz yapma
- Açıklamaları kısa tut
- Sadece isteneni yap
