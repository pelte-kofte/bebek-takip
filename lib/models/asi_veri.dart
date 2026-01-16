class AsiVeri {
  static List<Map<String, dynamic>> getTurkiyeAsiTakvimi() {
    return [
      // Doğumda
      {
        'id': 'hepb_1',
        'ad': 'Hepatit B',
        'donem': 'Doğumda',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': '1. Doz',
      },

      // 2. Ay
      {
        'id': 'bcg',
        'ad': 'BCG (Verem)',
        'donem': '2. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': '',
      },
      {
        'id': 'karma_1',
        'ad': 'Karma Aşı (5\'li)',
        'donem': '2. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': 'DabT-IPA-Hib - 1. Doz',
      },
      {
        'id': 'rota_1',
        'ad': 'Rota Virüs',
        'donem': '2. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': '1. Doz',
      },
      {
        'id': 'kpa_1',
        'ad': 'KPA 13',
        'donem': '2. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': 'Pnömokok - 1. Doz',
      },

      // 4. Ay
      {
        'id': 'karma_2',
        'ad': 'Karma Aşı (5\'li)',
        'donem': '4. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': 'DabT-IPA-Hib - 2. Doz',
      },
      {
        'id': 'rota_2',
        'ad': 'Rota Virüs',
        'donem': '4. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': '2. Doz',
      },
      {
        'id': 'kpa_2',
        'ad': 'KPA 13',
        'donem': '4. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': 'Pnömokok - 2. Doz',
      },

      // 6. Ay
      {
        'id': 'karma_3',
        'ad': 'Karma Aşı (5\'li)',
        'donem': '6. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': 'DabT-IPA-Hib - 3. Doz',
      },
      {
        'id': 'hepb_2',
        'ad': 'Hepatit B',
        'donem': '6. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': '3. Doz',
      },
      {
        'id': 'rota_3',
        'ad': 'Rota Virüs',
        'donem': '6. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': '3. Doz (opsiyonel)',
      },

      // 12. Ay
      {
        'id': 'kpa_3',
        'ad': 'KPA 13',
        'donem': '12. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': 'Pnömokok - Rapel',
      },
      {
        'id': 'kka',
        'ad': 'KKK (Kızamık-Kızamıkçık-Kabakulak)',
        'donem': '12. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': '1. Doz',
      },

      // 18. Ay
      {
        'id': 'karma_4',
        'ad': 'Karma Aşı (5\'li)',
        'donem': '18. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': 'DabT-IPA-Hib - Rapel',
      },
      {
        'id': 'hepA_1',
        'ad': 'Hepatit A',
        'donem': '18. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': '1. Doz',
      },
      {
        'id': 'suCicegi',
        'ad': 'Suçiçeği',
        'donem': '18. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': '',
      },

      // 24. Ay
      {
        'id': 'hepA_2',
        'ad': 'Hepatit A',
        'donem': '24. Ay',
        'durum': 'bekleniyor',
        'tarih': null,
        'notlar': '2. Doz',
      },
    ];
  }

  static Map<String, String> getDonemDisplayName(String donem) {
    const map = {
      'Doğumda': 'Doğumda',
      '2. Ay': '2. Ay',
      '4. Ay': '4. Ay',
      '6. Ay': '6. Ay',
      '12. Ay': '12. Ay',
      '18. Ay': '18. Ay',
      '24. Ay': '24. Ay',
    };
    return map;
  }
}
