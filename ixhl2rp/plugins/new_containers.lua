local PLUGIN = PLUGIN

PLUGIN.name = "New Containers"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

ix.lang.AddTable("ru", {
	["container.fridge_modern"] = "Современный холодильник",
	["container.fridge_modern_desc"] = "Довольно приятный на вид холодильник, который был собран совсем недавно. Чистый, опрятный и, что самое главное - вместительный.",
	["container.fridge_big"] = "Большой современный холодильник",
	["container.fridge_big_desc"] = "Холодильник с большой морозильной камерой и множеством места прямо в дверцах. Пахнет и выглядит очень приятно, а на задней его стороне красуется эмблема 'Сделано в Сити-8'.",
	["container.closet"] = "Шкаф для одежды",
	["container.closet_desc"] = "Старый, немного побитый шкаф. Очень громоздкий, но довольно вместительный. Главное - не поломать его.",
	["container.drawer_high"] = "Высокая тумбочка",
	["container.drawer_high_desc"] = "Выглядит довольно старой, но высота и довольно глубокие ящички в этой тумбочке делают ее.. немного вместительной. Стоит быть аккуратнее с некоторыми ящичками, ибо у них отваливаются ручки!",
	["container.drawer_small"] = "Тумбочка",
	["container.drawer_small_desc"] = "Старенькая тумбочка всего с одним ящичком. Не очень вместительная, но будет приятным дополнением для хранения снотворного или других безделушек.",
	["container.drawer_chest"] = "Комод",
	["container.drawer_chest_desc"] = "Дряхлый, но вместительный комод. Он станет надежным другом для любого любителя как красивого дизайна, так и вместительной природы этого деревянного чуда.",
	["container.cupboard_wall"] = "Настенная тумбочка",
	["container.cupboard_wall_desc"] = "Тумба, которая вешается на стену. По закону подлости правая дверца не имеет ручки, что нервирует, но не особо мешает.",
	["container.medical_cabinet"] = "Настенная аптечка",
	["container.medical_cabinet_desc"] = "Новая железная тумба-аптечка, которая не смотря на свою красоту является невместительной.",
	["container.tool_cabinet"] = "Шкаф с инструментами",
	["container.tool_cabinet_desc"] = "Красный и большой шкафчик, в который может, кажется, поместиться два с половиной человека.",
	["container.desk"] = "Письменный столик",
	["container.desk_desc"] = "Этот обшарпанный стол станет приятным дополнением для людей, которые все еще помнят о том, что им нужно сделать письменное задание.",
	["container.parts_bin"] = "Ящик с ячейками",
	["container.parts_bin_desc"] = "В него можно сложить очень много мелочи.. наверное.",
	["container.crate_wood"] = "Ящик",
	["container.crate_wood_desc"] = "Универсальный контейнер, изготовленный из древесины, предназначенный для хранения и транспортировки различных товаров и предметов.",
	["container.lockers"] = "Шкафчики",
	["container.lockers_desc"] = "Металлические шкафчики, обычно использующиеся, чтобы в них слаживали личные вещи или недоеденный сэндвич.",
	["container.metal_cabinet"] = "Металлический шкаф",
	["container.metal_cabinet_desc"] = "Надежное хранилище, которое идеально подходит для использования в офисах, складах, мастерских и образовательных учреждениях.",
	["container.file_small"] = "Малая картотека",
	["container.file_small_desc"] = "Компактный выдвижной ящик, идеально подходящий для организации и упорядочивания карточек с заметками. Но даже для этого он очень мал.",
	["container.file_tall"] = "Высокая картотека",
	["container.file_tall_desc"] = "Шкаф с выдвижными ящиками, в котором хранятся различные карточки или документы, так должно быть.",
	["container.file_medium"] = "Средняя картотека",
	["container.file_medium_desc"] = "Металлический ящик, в котором можно хранить картотеки и книги, но помимо этого найдется места и другим предметам!",
	["container.fridge_old"] = "Старый холодильник",
	["container.fridge_old_desc"] = "Верный спутник времени, что прошел через десятки лет.  Его корпус, покрытый пятнами времени и следами использования, а дверца открывается с резким скрипом.",
	["container.fridge_large"] = "Большой холодильник",
	["container.fridge_large_desc"] = "Техническое чудо, способное сохранить огромные объемы продуктов на оптимальной температуре. ",
	["container.trashbin"] = "Мусорка",
	["container.trashbin_desc"] = "Функциональный синий контейнер для отходов, из него исходит вонь отходов.",
	["container.dumpster"] = "Металлический бак",
	["container.dumpster_desc"] = "Надежный страж чистоты и порядка в любом общественном или частном пространстве. На нем краска давно потрескалась, а откидная крышка каждый раз издает неприятный скрип.",
	["container.ammo_crate"] = "Металлический ящик",
	["container.ammo_crate_desc"] = "Ящик, снабженный специальными зажимами, обеспечивающими надежное закрепление крышки и предотвращающие несанкционированный доступ к содержимому.",
	["container.footlocker"] = "Сундук",
	["container.footlocker_desc"] = "Это прочный ящик с крышкой, обычно изготовленный из дерева для хранения разного хлама.",
	["container.crate_small"] = "Небольшой ящик",
	["container.crate_small_desc"] = "Изготовленный из прочной древесины, ящик предназначен для транспортировки в самые трудные места.",
	["container.cash_register"] = "Касса",
	["container.cash_register_desc"] = "Надежное хранилище для ваших денег с множеством разных кнопочек и выдвижным ящиком.",
	["container.archive"] = "Архив",
	["container.archive_desc"] = "Тут можно сложить очень много бумаги или других интересных вещей.",
	["container.combine_crate"] = "Контейнер Надзора",
	["container.combine_crate_desc"] = "Массивный ящик Альянса, выполненный из сплава титана и армированной стали. Поручень позволяет поднять массивную крышку. Сам контейнер предназначен для траннспортировки оружия, боеприпасов - и имеет термоконтроль. Произведен в Сити-17.",
	["container.combine_medium"] = "Средний ящик Надзора",
	["container.combine_medium_desc"] = "Сделанный из сплава титана и армированной стали ящик, с встроенным электронным замком и поручнями для удобной транспортировки. Внутри установлен аккумулятор, а также несколько тусклых ламп для освещения ваших сокровищ.",
	["container.combine_small"] = "Малый ящик Надзора",
	["container.combine_small_desc"] = "Малый кейс с символом Альянса на нем, выполненный из крепкого сплава титана и армированной стали. Встроенный в корпус электронный замок позволяет защитить ваши пожитки. Плохо сохраняет температуру.",
})
ix.lang.AddTable("en", {
	["container.fridge_modern"] = "Modern refrigerator",
	["container.fridge_modern_desc"] = "A pleasant-looking refrigerator assembled recently. Clean, tidy and, most importantly, roomy.",
	["container.fridge_big"] = "Large modern refrigerator",
	["container.fridge_big_desc"] = "A refrigerator with a large freezer and plenty of space in the doors. Smells and looks very nice, with a 'Made in City-8' emblem on the back.",
	["container.closet"] = "Wardrobe",
	["container.closet_desc"] = "An old, worn wardrobe. Bulky but quite roomy. Just don't break it.",
	["container.drawer_high"] = "Tall nightstand",
	["container.drawer_high_desc"] = "Looks rather old, but the height and deep drawers make it somewhat roomy. Be careful with some drawers—the handles fall off!",
	["container.drawer_small"] = "Nightstand",
	["container.drawer_small_desc"] = "A small old nightstand with a single drawer. Not very roomy, but good for sleeping pills or knick-knacks.",
	["container.drawer_chest"] = "Dresser",
	["container.drawer_chest_desc"] = "A worn but roomy dresser. A reliable friend for anyone who likes both design and storage space.",
	["container.cupboard_wall"] = "Wall cabinet",
	["container.cupboard_wall_desc"] = "A cabinet that hangs on the wall. The right door has no handle, which is annoying but not a real problem.",
	["container.medical_cabinet"] = "Wall medical cabinet",
	["container.medical_cabinet_desc"] = "A new metal first-aid cabinet that, despite its looks, is not very roomy.",
	["container.tool_cabinet"] = "Tool cabinet",
	["container.tool_cabinet_desc"] = "A big red cabinet that could probably fit two and a half people inside.",
	["container.desk"] = "Writing desk",
	["container.desk_desc"] = "This worn desk is a nice addition for anyone who still remembers they have written assignments to do.",
	["container.parts_bin"] = "Parts bin",
	["container.parts_bin_desc"] = "You can fit a lot of small stuff in here... probably.",
	["container.crate_wood"] = "Crate",
	["container.crate_wood_desc"] = "A universal wooden container for storing and transporting various goods and items.",
	["container.lockers"] = "Lockers",
	["container.lockers_desc"] = "Metal lockers usually used for personal belongings or half-eaten sandwiches.",
	["container.metal_cabinet"] = "Metal cabinet",
	["container.metal_cabinet_desc"] = "Reliable storage ideal for offices, warehouses, workshops and educational institutions.",
	["container.file_small"] = "Small file cabinet",
	["container.file_small_desc"] = "A compact filing cabinet, ideal for organizing note cards. Still quite small for that.",
	["container.file_tall"] = "Tall file cabinet",
	["container.file_tall_desc"] = "A cabinet with sliding drawers for storing various cards or documents, as it should be.",
	["container.file_medium"] = "Medium file cabinet",
	["container.file_medium_desc"] = "A metal cabinet for files and books, with room for other items too!",
	["container.fridge_old"] = "Old refrigerator",
	["container.fridge_old_desc"] = "A faithful companion through the decades. Its body is stained by time and use, and the door opens with a sharp creak.",
	["container.fridge_large"] = "Large refrigerator",
	["container.fridge_large_desc"] = "A technical marvel that can keep large amounts of food at the right temperature.",
	["container.trashbin"] = "Trash bin",
	["container.trashbin_desc"] = "A functional blue waste container that reeks of garbage.",
	["container.dumpster"] = "Metal dumpster",
	["container.dumpster_desc"] = "A reliable guardian of cleanliness. The paint is cracked and the lid creaks every time.",
	["container.ammo_crate"] = "Metal crate",
	["container.ammo_crate_desc"] = "A crate with special clamps that secure the lid and prevent unauthorized access.",
	["container.footlocker"] = "Footlocker",
	["container.footlocker_desc"] = "A sturdy box with a lid, usually made of wood for storing various junk.",
	["container.crate_small"] = "Small crate",
	["container.crate_small_desc"] = "Made of sturdy wood, this crate is built for transport to the roughest places.",
	["container.cash_register"] = "Cash register",
	["container.cash_register_desc"] = "A reliable place for your money with lots of buttons and a drawer.",
	["container.archive"] = "Archive",
	["container.archive_desc"] = "You can store a lot of paper or other interesting things here.",
	["container.combine_crate"] = "Overwatch container",
	["container.combine_crate_desc"] = "A massive Alliance crate of titanium and reinforced steel. The handle lets you lift the heavy lid. Meant for transporting weapons and ammo, with climate control. Made in City-17.",
	["container.combine_medium"] = "Medium Overwatch crate",
	["container.combine_medium_desc"] = "A crate of titanium and reinforced steel with an electronic lock and handles. Fitted with a battery and dim lights for your valuables.",
	["container.combine_small"] = "Small Overwatch crate",
	["container.combine_small_desc"] = "A small case with the Alliance symbol, made of strong titanium alloy. The built-in lock protects your belongings. Poor temperature retention.",
})
ix.lang.AddTable("fr", {
	["container.fridge_modern"] = "Réfrigérateur moderne",
	["container.fridge_modern_desc"] = "Un réfrigérateur agréable à l'œil, assemblé récemment. Propre et spacieux.",
	["container.fridge_big"] = "Grand réfrigérateur moderne",
	["container.fridge_big_desc"] = "Un réfrigérateur avec grand congélateur et beaucoup d'espace dans les portes. Sent bon et a l'air bien, avec l'emblème 'Fabriqué à City-8'.",
	["container.closet"] = "Garde-robe",
	["container.closet_desc"] = "Une vieille garde-robe usée. Encombrante mais assez spacieuse.",
	["container.drawer_high"] = "Table de chevet haute",
	["container.drawer_high_desc"] = "Assez vieille, mais la hauteur et les tiroirs profonds la rendent spacieuse. Attention aux poignées qui tombent.",
	["container.drawer_small"] = "Table de chevet",
	["container.drawer_small_desc"] = "Une vieille table de chevet avec un tiroir. Pas très spacieuse, mais pratique pour les somnifères ou bibelots.",
	["container.drawer_chest"] = "Commode",
	["container.drawer_chest_desc"] = "Une commode usée mais spacieuse. Fiable pour qui aime le design et le rangement.",
	["container.cupboard_wall"] = "Placard mural",
	["container.cupboard_wall_desc"] = "Un placard accroché au mur. La porte droite n'a pas de poignée, c'est agaçant mais pas bloquant.",
	["container.medical_cabinet"] = "Armoire à pharmacie murale",
	["container.medical_cabinet_desc"] = "Une nouvelle armoire à pharmacie en fer, belle mais peu spacieuse.",
	["container.tool_cabinet"] = "Armoire à outils",
	["container.tool_cabinet_desc"] = "Une grande armoire rouge où pourraient tenir deux personnes et demie.",
	["container.desk"] = "Bureau",
	["container.desk_desc"] = "Ce bureau usé convient à ceux qui se souviennent encore des devoirs écrits à faire.",
	["container.parts_bin"] = "Bac à pièces",
	["container.parts_bin_desc"] = "On peut y ranger beaucoup de petits trucs... peut-être.",
	["container.crate_wood"] = "Caisse",
	["container.crate_wood_desc"] = "Conteneur en bois universel pour stocker et transporter des marchandises.",
	["container.lockers"] = "Casiers",
	["container.lockers_desc"] = "Des casiers métalliques pour les affaires personnelles ou les sandwichs à moitié mangés.",
	["container.metal_cabinet"] = "Armoire métallique",
	["container.metal_cabinet_desc"] = "Stockage fiable pour bureaux, entrepôts, ateliers et établissements.",
	["container.file_small"] = "Petit classeur",
	["container.file_small_desc"] = "Classeur compact pour fiches et notes. Très petit.",
	["container.file_tall"] = "Grand classeur",
	["container.file_tall_desc"] = "Armoire à tiroirs pour cartes et documents.",
	["container.file_medium"] = "Classeur moyen",
	["container.file_medium_desc"] = "Armoire métallique pour classeurs et livres, avec de la place pour le reste.",
	["container.fridge_old"] = "Vieux réfrigérateur",
	["container.fridge_old_desc"] = "Fidèle compagnon des décennies. La porte grince à l'ouverture.",
	["container.fridge_large"] = "Grand réfrigérateur",
	["container.fridge_large_desc"] = "Merveille technique pour garder de grandes quantités de nourriture au frais.",
	["container.trashbin"] = "Poubelle",
	["container.trashbin_desc"] = "Conteneur bleu fonctionnel qui sent les déchets.",
	["container.dumpster"] = "Benne métallique",
	["container.dumpster_desc"] = "Gardien de la propreté. La peinture est craquelée et le couvercle grince.",
	["container.ammo_crate"] = "Caisse métallique",
	["container.ammo_crate_desc"] = "Caisse à fermeture sécurisée empêchant l'accès non autorisé.",
	["container.footlocker"] = "Cantine",
	["container.footlocker_desc"] = "Coffre en bois robuste pour ranger des bricoles.",
	["container.crate_small"] = "Petite caisse",
	["container.crate_small_desc"] = "Caisse en bois robuste pour le transport en terrain difficile.",
	["container.cash_register"] = "Caisse enregistreuse",
	["container.cash_register_desc"] = "Rangement fiable pour l'argent, avec boutons et tiroir.",
	["container.archive"] = "Archive",
	["container.archive_desc"] = "On peut y ranger beaucoup de papier ou d'autres choses.",
	["container.combine_crate"] = "Conteneur Overwatch",
	["container.combine_crate_desc"] = "Caisse massive de l'Alliance en titane et acier. Poignée pour soulever le couvercle. Transport d'armes et munitions, climatisation. Fabriqué à City-17.",
	["container.combine_medium"] = "Caisse Overwatch moyenne",
	["container.combine_medium_desc"] = "Caisse en titane et acier avec serrure électronique et poignées. Batterie et lampes pour vos trésors.",
	["container.combine_small"] = "Petite caisse Overwatch",
	["container.combine_small_desc"] = "Petite mallette au symbole de l'Alliance, alliage de titane. Serrure intégrée. Mauvaise isolation thermique.",
})
ix.lang.AddTable("es-es", {
	["container.fridge_modern"] = "Refrigerador moderno",
	["container.fridge_modern_desc"] = "Refrigerador de aspecto agradable, montado hace poco. Limpio y espacioso.",
	["container.fridge_big"] = "Refrigerador grande moderno",
	["container.fridge_big_desc"] = "Refrigerador con gran congelador y espacio en las puertas. Huele y se ve bien, con emblema 'Hecho en City-8'.",
	["container.closet"] = "Armario",
	["container.closet_desc"] = "Armario viejo y gastado. Voluminoso pero bastante espacioso.",
	["container.drawer_high"] = "Mesita alta",
	["container.drawer_high_desc"] = "Algo vieja, pero la altura y los cajones profundos la hacen espaciosa. Cuidado con las manillas.",
	["container.drawer_small"] = "Mesita",
	["container.drawer_small_desc"] = "Mesita vieja con un cajón. Poco espaciosa, pero útil para pastillas o baratijas.",
	["container.drawer_chest"] = "Cómoda",
	["container.drawer_chest_desc"] = "Cómoda gastada pero espaciosa. Fiable para quien gusta del diseño y el almacenaje.",
	["container.cupboard_wall"] = "Armario de pared",
	["container.cupboard_wall_desc"] = "Armario que cuelga de la pared. La puerta derecha no tiene manilla.",
	["container.medical_cabinet"] = "Botiquín de pared",
	["container.medical_cabinet_desc"] = "Botiquín metálico nuevo, bonito pero poco espacioso.",
	["container.tool_cabinet"] = "Armario de herramientas",
	["container.tool_cabinet_desc"] = "Armario rojo grande donde cabrían dos personas y media.",
	["container.desk"] = "Escritorio",
	["container.desk_desc"] = "Este escritorio gastado sirve a quien aún recuerda los deberes escritos.",
	["container.parts_bin"] = "Caja de piezas",
	["container.parts_bin_desc"] = "Se puede guardar mucho pequeño aquí... quizá.",
	["container.crate_wood"] = "Caja",
	["container.crate_wood_desc"] = "Contenedor de madera universal para almacenar y transportar mercancías.",
	["container.lockers"] = "Taquillas",
	["container.lockers_desc"] = "Taquillas metálicas para cosas personales o sandwiches a medias.",
	["container.metal_cabinet"] = "Armario metálico",
	["container.metal_cabinet_desc"] = "Almacenamiento fiable para oficinas, almacenes y talleres.",
	["container.file_small"] = "Archivador pequeño",
	["container.file_small_desc"] = "Archivador compacto para fichas y notas. Muy pequeño.",
	["container.file_tall"] = "Archivador alto",
	["container.file_tall_desc"] = "Armario con cajones para fichas y documentos.",
	["container.file_medium"] = "Archivador mediano",
	["container.file_medium_desc"] = "Armario metálico para archivadores y libros, con sitio para más.",
	["container.fridge_old"] = "Refrigerador viejo",
	["container.fridge_old_desc"] = "Fiel compañero de décadas. La puerta cruje al abrir.",
	["container.fridge_large"] = "Refrigerador grande",
	["container.fridge_large_desc"] = "Maravilla técnica para mantener mucha comida a la temperatura correcta.",
	["container.trashbin"] = "Papelera",
	["container.trashbin_desc"] = "Contenedor azul funcional que huele a basura.",
	["container.dumpster"] = "Contenedor metálico",
	["container.dumpster_desc"] = "Guardián de la limpieza. Pintura agrietada y tapa que cruje.",
	["container.ammo_crate"] = "Caja metálica",
	["container.ammo_crate_desc"] = "Caja con cierres que aseguran la tapa y evitan acceso no autorizado.",
	["container.footlocker"] = "Baúl",
	["container.footlocker_desc"] = "Caja robusta con tapa, normalmente de madera, para guardar trastos.",
	["container.crate_small"] = "Caja pequeña",
	["container.crate_small_desc"] = "Hecha de madera resistente para transportar a sitios difíciles.",
	["container.cash_register"] = "Caja registradora",
	["container.cash_register_desc"] = "Lugar fiable para el dinero, con botones y cajón.",
	["container.archive"] = "Archivo",
	["container.archive_desc"] = "Se puede guardar mucho papel u otras cosas aquí.",
	["container.combine_crate"] = "Contenedor Overwatch",
	["container.combine_crate_desc"] = "Caja masiva de la Alianza en titanio y acero. Asa para levantar la tapa. Transporte de armas y munición, climatización. Hecho en City-17.",
	["container.combine_medium"] = "Caja Overwatch mediana",
	["container.combine_medium_desc"] = "Caja de titanio y acero con cerradura electrónica y asas. Batería y luces tenues para tus cosas.",
	["container.combine_small"] = "Caja Overwatch pequeña",
	["container.combine_small_desc"] = "Maletín pequeño con símbolo de la Alianza, aleación de titanio. Cerradura integrada. Poca retención de temperatura.",
})

ix.container.Register("models/props_interiors/refrigerator03.mdl", {
	name = "container.fridge_modern",
	description = "container.fridge_modern_desc",
	width = 4,
	height = 6,
})

ix.container.Register("models/sickness/fridge_01.mdl", {
	name = "container.fridge_big",
	description = "container.fridge_big_desc",
	width = 5,
	height = 9,
})

ix.container.Register("models/props_c17/furnituredresser001a.mdl", {
	name = "container.closet",
	description = "container.closet_desc",
	width = 6,
	height = 8,
})

ix.container.Register("models/props_c17/furnituredrawer003a.mdl", {
	name = "container.drawer_high",
	description = "container.drawer_high_desc",
	width = 3,
	height = 4,
})

ix.container.Register("models/props_c17/furnituredrawer002a.mdl", {
	name = "container.drawer_small",
	description = "container.drawer_small_desc",
	width = 4,
	height = 3,
})

ix.container.Register("models/props_c17/furnituredrawer001a.mdl", {
	name = "container.drawer_chest",
	description = "container.drawer_chest_desc",
	width = 6,
	height = 4,
})

ix.container.Register("models/props_c17/furniturecupboard001a.mdl", {
	name = "container.cupboard_wall",
	description = "container.cupboard_wall_desc",
	width = 3,
	height = 3,
})

ix.container.Register("models/props_interiors/medicalcabinet02.mdl", {
	name = "container.medical_cabinet",
	description = "container.medical_cabinet_desc",
	height = 4,
	width = 4
})

ix.container.Register("models/props_warehouse/toolbox.mdl", {
	name = "container.tool_cabinet",
	description = "container.tool_cabinet_desc",
	height = 8,
	width = 8
})

ix.container.Register("models/props_interiors/furniture_desk01a.mdl", {
	name = "container.desk",
	description = "container.desk_desc",
	height = 6,
	width = 3
})

ix.container.Register("models/props_lab/partsbin01.mdl", {
	name = "container.parts_bin",
	description = "container.parts_bin_desc",
	height = 3,
	width = 3
})

ix.container.Register("models/props_junk/wood_crate001a.mdl", {
	name = "container.crate_wood",
	description = "container.crate_wood_desc",
	width = 6,
	height = 6,
})

ix.container.Register("models/props_c17/lockers001a.mdl", {
	name = "container.lockers",
	description = "container.lockers_desc",
	width = 4,
	height = 5,
})

ix.container.Register("models/props_wasteland/controlroom_storagecloset001a.mdl", {
	name = "container.metal_cabinet",
	description = "container.metal_cabinet_desc",
	width = 10,
	height = 10,
})

ix.container.Register("models/props_wasteland/controlroom_filecabinet001a.mdl", {
	name = "container.file_small",
	description = "container.file_small_desc",
	width = 2,
	height = 3
})

ix.container.Register("models/props_wasteland/controlroom_filecabinet002a.mdl", {
	name = "container.file_tall",
	description = "container.file_tall_desc",
	width = 4,
	height = 5,
})

ix.container.Register("models/props_lab/filecabinet02.mdl", {
	name = "container.file_medium",
	description = "container.file_medium_desc",
	width = 3,
	height = 4
})

ix.container.Register("models/props_c17/furniturefridge001a.mdl", {
	name = "container.fridge_old",
	description = "container.fridge_old_desc",
	width = 3,
	height = 6,
	bRefrigerator = true
})

ix.container.Register("models/props_wasteland/kitchen_fridge001a.mdl", {
	name = "container.fridge_large",
	description = "container.fridge_large_desc",
	width = 5,
	height = 7,
})

ix.container.Register("models/props_junk/trashbin01a.mdl", {
	name = "container.trashbin",
	description = "container.trashbin_desc",
	width = 2,
	height = 4,
})

ix.container.Register("models/props_junk/trashdumpster01a.mdl", {
	name = "container.dumpster",
	description = "container.dumpster_desc",
	width = 6,
	height = 6
})

ix.container.Register("models/items/ammocrate_smg1.mdl", {
	name = "container.ammo_crate",
	description = "container.ammo_crate_desc",
	width = 7,
	height = 3,
	OnOpen = function(entity, activator)
		local closeSeq = entity:LookupSequence("Close")
		entity:ResetSequence(closeSeq)

		timer.Simple(2, function()
			if (entity and IsValid(entity)) then
				local openSeq = entity:LookupSequence("Open")
				entity:ResetSequence(openSeq)
			end
		end)
	end
})

ix.container.Register("models/props_forest/footlocker01_closed.mdl", {
	name = "container.footlocker",
	description = "container.footlocker_desc",
	width = 5,
	height = 4
})

ix.container.Register("models/Items/item_item_crate.mdl", {
	name = "container.crate_small",
	description = "container.crate_small_desc",
	width = 4,
	height = 4
})

ix.container.Register("models/props_c17/cashregister01a.mdl", {
	name = "container.cash_register",
	description = "container.cash_register_desc",
	width = 2,
	height = 2
})

ix.container.Register("models/props_office/file_cabinet_large_static.mdl", {
	name = "container.archive",
	description = "container.archive_desc",
	width = 8,
	height = 3
})

ix.container.Register("models/props_combine/combine_crate_large_static.mdl", {
	name = "container.combine_crate",
	description = "container.combine_crate_desc",
	width = 12,
	height = 8
})

ix.container.Register("models/props_combine/combine_crate_medium_static.mdl", {
	name = "container.combine_medium",
	description = "container.combine_medium_desc",
	width = 5,
	height = 5
})

ix.container.Register("models/props_combine/combine_crate_small_static.mdl", {
	name = "container.combine_small",
	description = "container.combine_small_desc",
	width = 3,
	height = 4
})