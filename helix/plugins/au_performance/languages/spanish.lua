ix.Locale:Build("es-es")


option.gmod_mcore_test 					= "Procesamiento multihilo"
option.gmod_mcore_test.desc 			= "Habilita el procesamiento multihilo para tu juego. Requiere reinicio."

option.mat_queue_mode 					= "Modo de cola de materiales"
option.mat_queue_mode.desc 				= "El modo de cola/hilo que el sistema de materiales debe usar (-1 = predeterminado, 0 = síncrono de un solo hilo, 1 = en cola de un solo hilo, 2 = en cola multihilo)."

option.cl_threaded_bone_setup 			= "Sistema de huesos multihilo"
option.cl_threaded_bone_setup.desc 		= "Habilita el procesamiento paralelo para el sistema de huesos."

option.r_decals 						= "Número máx. de calcomanías"
option.r_decals.desc 					= "El número máximo de calcomanías que pueden mostrarse al mismo tiempo."

option.r_drawmodeldecals 				= "Calcomanías en modelos"
option.r_drawmodeldecals.desc 			= "Activar o desactivar el dibujado de calcomanías en modelos."

option.r_maxmodeldecal 					= "Calcomanías máx. en modelos"
option.r_maxmodeldecal.desc 			= "El número máximo de calcomanías que pueden mostrarse en modelos al mismo tiempo."

option.cl_ragdoll_collide 				= "Colisión de ragdolls del cliente"
option.cl_ragdoll_collide.desc 			= "Activar o desactivar colisiones para modelos del cliente."

option.r_WaterDrawReflection 			= "Reflejos en el agua"
option.r_WaterDrawReflection.desc 		= "Activar o desactivar reflejos en el agua."

option.r_WaterDrawRefraction 			= "Refracciones en el agua"
option.r_WaterDrawRefraction.desc 		= "Activar o desactivar refracciones en el agua."

option.r_shadows 						= "Sombras de modelos"
option.r_shadows.desc 					= "Activar o desactivar sombras proyectadas por modelos y objetos."

option.mat_mipmaptextures 				= "Texturas 'Mipmap'"
option.mat_mipmaptextures.desc 			= "Mejora la calidad de las texturas a costa del rendimiento."

option.mat_filtertextures 				= "Filtrado de texturas"
option.mat_filtertextures.desc 			= "Mejora la calidad de las texturas a costa del rendimiento."

option.mat_envmapsize 					= "Tamaño del mapa de entorno"
option.mat_envmapsize.desc 				= "Ajusta la resolución de los mapas de entorno usados para superficies reflectantes."

option.cl_phys_props_enable 			= "Física de objetos del cliente"
option.cl_phys_props_enable.desc 		= "Habilita la física del lado del cliente para objetos. Requiere reconexión."

option.cl_ejectbrass 					= "Expulsión de casquillos"
option.cl_ejectbrass.desc 				= "Activar o desactivar la expulsión de casquillos de las armas al disparar."

option.mat_filterlightmaps 				= "Filtrado de lightmaps"
option.mat_filterlightmaps.desc 		= "Mejora la calidad de la iluminación a costa del rendimiento."

option.muzzleflash_light 				= "Iluminación del fogonazo"
option.muzzleflash_light.desc 			= "Activar o desactivar la iluminación del fogonazo en el modelo del jugador."

option.props_break_max_pieces 			= "Número máx. de fragmentos de props"
option.props_break_max_pieces.desc 		= "El número máximo de fragmentos de props destructibles (-1 = predeterminado para el modelo)."

option.r_3dsky 							= "Skybox 3D"
option.r_3dsky.desc 					= "Activar o desactivar el renderizado de skyboxes 3D."

option.r_maxdlights 					= "Luces dinámicas máximas"
option.r_maxdlights.desc 				= "El número máximo de luces dinámicas que pueden existir al mismo tiempo."

option.r_eyemove 						= "Movimiento de ojos"
option.r_eyemove.desc 					= "Activar o desactivar el movimiento de ojos para personajes y NPCs."

option.r_eyes 							= "Visualización de ojos"
option.r_eyes.desc 						= "Activar o desactivar la visualización de ojos para personajes y NPCs."

option.r_teeth 							= "Visualización de dientes"
option.r_teeth.desc 					= "Activar o desactivar la visualización de dientes para personajes y NPCs."

option.r_radiosity 						= "Configuración de radiosidad"
option.r_radiosity.desc 				= "Método de muestreo de radiosidad (0 = sin radiosidad, 1 = radiosidad usando cubo de entorno (6 muestras), 2 = radiosidad con 162 muestras, 3 = 162 muestras para objetos estáticos, 6 muestras para todo lo demás)."

option.r_worldlights 					= "Iluminación del mundo"
option.r_worldlights.desc 				= "Número de luces del mundo usadas por vértice."

option.rope_averagelight 				= "Iluminación media para cuerdas"
option.rope_averagelight.desc 			= "Fuerza a las cuerdas a usar iluminación media del cubemap en lugar de intensidad máxima."

option.rope_collide 					= "Colisiones de cuerdas"
option.rope_collide.desc 				= "Activar o desactivar colisiones de cuerdas con el mundo."

option.rope_rendersolid 				= "Visualización de cuerdas"
option.rope_rendersolid.desc 			= "Activar o desactivar la visualización de cuerdas."

option.rope_smooth 						= "Suavizado de cuerdas"
option.rope_smooth.desc 				= "Activar o desactivar el suavizado de cuerdas."

option.rope_subdiv 						= "Subdivisión de cuerdas"
option.rope_subdiv.desc 				= "Número de sub-cuerdas."

option.violence_ablood 					= "Sangre zombie/alien"
option.violence_ablood.desc 			= "Activar o desactivar la visualización de sangre zombie/alien."

option.violence_agibs 					= "Gibs zombie/alien"
option.violence_agibs.desc 				= "Activar o desactivar la visualización de gibs zombie/alien."

option.violence_hblood 					= "Sangre humana"
option.violence_hblood.desc 			= "Activar o desactivar la visualización de sangre."

option.violence_hgibs 					= "Gibs humanos"
option.violence_hgibs.desc 				= "Activar o desactivar la visualización de gibs."

option.ai_expression_optimization 		= "Optimización de expresiones IA"
option.ai_expression_optimization.desc 	= "Activar o desactivar expresiones de NPCs cuando no puedes verlos."

option.cl_detaildist					= "Distancia de detalle"
option.cl_detaildist.desc 				= "Distancia a la que los detalles de objetos se vuelven invisibles."

option.cl_detailfade 					= "Desvanecimiento de detalle"
option.cl_detailfade.desc 				= "Distancia a la que los detalles de objetos aparecen suavemente."

option.r_fastzreject 					= "Rechazo Z rápido"
option.r_fastzreject.desc 				= "Activa/desactiva la configuración de rechazo Z rápido para aprovechar hardware con rechazo Z rápido. Usa -1 para volver a la configuración predeterminada."

option.cl_show_splashes 				= "Visualización de salpicaduras de agua"
option.cl_show_splashes.desc 			= "Activar o desactivar la visualización de salpicaduras de agua."

option.r_drawflecks 					= "Visualización de fragmentos"
option.r_drawflecks.desc 				= "Activar o desactivar la creación de partículas al disparar a paredes."

option.r_threaded_particles 			= "Sistema de partículas multihilo"
option.r_threaded_particles.desc 		= "Habilita el procesamiento paralelo para el sistema de partículas."

option.snd_mix_async 					= "Sistema de sonido multihilo"
option.snd_mix_async.desc 				= "Habilita el procesamiento paralelo para el sistema de sonido."

option.r_threaded_renderables 			= "Sistema de renderizado multihilo"
option.r_threaded_renderables.desc 		= "Habilita el procesamiento paralelo para el sistema de renderizado."

option.cl_forcepreload 					= "Precarga forzada"
option.cl_forcepreload.desc 			= "Fuerza la precarga de todo el contenido antes de cargar el mapa, en lugar de cargar según sea necesario."
