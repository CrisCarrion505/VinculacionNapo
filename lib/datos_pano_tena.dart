/// Lista de ubicaciones, lugares turísticos y servicios en Pano, Tena
const List<String> ubicacionesPanoTena = [
  // Calles principales
  'Avenida Pano Yaya',
  'Bandiu',
  'Calle 3',
  'Calle 6',
  'Calle A',
  'Chukuri',
  'Kuraka',
  'Mancino',
  'Mangu',
  'Vía Talag',

  // Balnearios
  'Balneario Juan Bueno',
  'Balneario Lagartococha',
  'Balneario Pano',
  'Balneario Pikitzacocha',
  'Balneario Pikitzacucha',
  'Balneario Puka Urku',
  'Balneario Pumarumi',
  'Balneario Rumicocha',
  'Balneario San Andrés',
  'Balneario San Bartolomé de Imbu',
  'Balneario San Carlos',
  'Balneario Yaracocha',

  // Cascadas
  'Cascada de Achiyacu',
  'Cascada en Bosque de los Sueños',

  // Cañones
  'Cañón',
  'Cañón de Yurak Rumi Ñambi',
  'Cañón Supaypaccha Uctu',

  // Miradores
  'Mirador Rayuurcu',
  'Mirador Rayuurcu 2',
  'Mirador Sacha Urco',

  // Petroglifos
  'Petroglifo Pumarumi',
  'Petroglifo Winaru Purishcarumi',

  // Cuerpos de agua
  'Rumi Cocha',
  'Rumicocha',

  // Hospedaje y alojamiento
  'Hostería Napusamai Pasourcu Lodge',

  // Centros comunitarios
  'Centro Comunitario Alto Pano',
  'Centro Comunitario Bandio Alonso',
  'Centro Comunitario Lagarto Cocha',
  'Centro Comunitario Las Palmas',
  'Centro Comunitario Pumayacu',
  'Centro Comunitario San Bartolo de Uchukulin',
  'Centro Comunitario Sapo Rumi',
  'Centro Comunitario Tasaurcu',

  // Servicios de salud
  'Subcentro de Salud Pública Avenida Pano Yaya',

  // Educación
  'Unidad Educativa Bilingue El Pano',
  'Unidad Educativa Guillermo Kadle',

  // Centros de culto
  'Iglesia Católica Mangu',
  'Iglesia Evangélica Alianza Cristiana y Misionera Nueva Vida Pano',

  // Administración
  'GAD Parroquial Pano',
];

/// Mapeo de tipos de servicio turístico a ubicaciones disponibles
const Map<String, List<String>> servicioUbicacionesMap = {
  'Albergues': [
    'Hostería Napusamai Pasourcu Lodge',
  ],
  'Hospedajes rurales': [
    'Hospedaje Alto Pano',
    'Hospedaje Pano Centro',
  ],
  'Rutas de turismo vivencial': [
    'Ruta Bosque de los Sueños',
    'Ruta Cascada Achiyacu',
  ],
  'Experiencias astronómicas autóctonas': [
    'Mirador Rayuurcu',
    'Mirador Sacha Urco',
  ],
  'Artesanía local': [
    'Centro Artesanal Alto Pano',
    'Centro Artesanal Pano',
  ],
  'Productos locales': [
    'Mercado Pano',
    'Tienda Local Pano',
  ],
  'Patrimonio natural': [
    'Petroglifo Pumarumi',
    'Rumi Cocha',
    'Cañón Supaypaccha Uctu',
  ],
  'Balnearios': [
    'Balneario Juan Bueno',
    'Balneario Lagartococha',
    'Balneario Pano',
    'Balneario Pikitzacocha',
    'Balneario Puka Urku',
    'Balneario Pumarumi',
    'Balneario Rumicocha',
    'Balneario San Andrés',
    'Balneario San Bartolomé de Imbu',
    'Balneario San Carlos',
    'Balneario Yaracocha',
  ],
};

/// Lista de tipos de servicios turísticos disponibles
const List<String> tiposServicioTuristico = [
  'Albergues',
  'Hospedajes rurales',
  'Rutas de turismo vivencial',
  'Experiencias astronómicas autóctonas',
  'Artesanía local',
  'Productos locales',
  'Patrimonio natural',
  'Balnearios',
];
