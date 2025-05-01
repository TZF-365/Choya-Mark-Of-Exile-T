extends PanelContainer
class_name GameOver

@onready var flavorinfo: Label = $MarginContainer/HBoxContainer2/Panel/Flavorinfo
@onready var background: Panel = $MarginContainer/VBoxContainer/Panel

var fade_colors = [
	Color(0.2, 0.1, 0.3),  # Dark purple
	Color(0.1, 0.2, 0.4),  # Deep blue
	Color(0.3, 0.1, 0.1),  # Blood red
	Color(0.1, 0.3, 0.2),  # Forest green
	Color(0.2, 0.2, 0.2)   # Neutral dark
]

var current_color_index = 0

var flavor_texts = [
	"In the ruins of Talbot, echoes of valor still haunt the wind—whispers of battles fought by souls who refused to yield, even when all hope was lost.",
	"Legends say a Drukdar wept once—when it saw the courage of humankind defy even the demon king, rising again and again from ruin.",
	"Magic surges may have passed, but the scars they left remain eternal—etched into stone, soul, and sky, marking the world forever changed.",
	"The blades forged in Talbot cut more than flesh—they cut through fate itself, severing the chains that once bound mankind to extinction.",
	"Even in defeat, the will of the Arkenhome never fades. Its fallen banners still flutter in the wind, calling brave hearts to rise again.",
	"Some say the mana storms were not the end, but the beginning of something greater—a crucible from which new legends of humanity were born, this was made true when Stormbringer became known.",
	"Not all monsters live in caves—some wear the faces of friends, speaking lies with familiar voices while daggers rest behind their backs.",
	"Your fall is but a whisper in the long saga of humanity's survival—just another spark in the forge where heroes are born.",
	"They once feared the dark, until they became it. So too may you rise—not as prey, but as shadow, fire, and reckoning itself.",
	"In a feat that shall echo through the ages, the Clan of Heroes, by their own strength and stratagem, did vanquish a nefarious host—a gathering of three hundred wretches bound by darkness and foul trade. These villains, steeped in wicked acts such as the bartering of man and beast alike, held dominion over the region of Terran. Yet, swift as a falcon’s dive and resolute as tempered steel, the Clan descended upon them. In but a fortnight, the scourge was cleansed, and the name of the Clan ascended further into legend.",
	"Thereafter came the Battle of Broken Vale, where the land shook beneath the tread of an endless horde. Beasts from every cursed corner of Valemor rallied ‘neath a single monstrous warlord—an abomination who had brought dread for decades untold. Yet the Clan, through cunning and power unmatched, met the foe with fire and fury. Their tactics cut like blades through the mass, and by sundown the warlord’s head lay still upon the bloodied earth. Peace returned to the land, and the people sang of their saviors. \n\n-History of the fallen Warlords",
	"Of their number, few are as feared—or revered—as Eira Blackflame, bearer of the Singular title of Black Mage. Mistress of elemental fury, she commandeth fire, lightning, and tempest with but a thought. Her wrath on the field of battle is likened to a walking cataclysm, and many a siege was ended ere it began at the sight of her arrival. Her might, some claim, rivals the destruction wrought by entire armies. Where she treads, the very elements bow. Rumors now stir in hushed tones—that one of the Four Legendary Heroes walketh once more among the lands, her presence whispered of within the Sylvan Concord, a place many claim as her birthright, though scholars yet quarrel over the truth.",
	"These monsters were unlike anything humanity had ever encountered. They were larger than bears, stronger and more ferocious than any known race on Earth, and terrifying in their relentless aggression. Adding to the threat was a new type of monster plankton that generated mana, thriving in areas where normal plankton could not exist. Strange fungi began dotting the land, remnants of the monsters and their environment. The soil, teeming with unfamiliar insects and bugs, and the alien plants further reshaped Earth's ecosystems.\n\nExcerpt From Arc 32",
	"The Clan of Heroes is not alone in its might; loyal companions bear them through war and shadow. These noble mounts—be they battle-trained wyverns, saber-toothed tigers, or even dragons of ancient blood—are bound to their riders in mutual respect. These beasts are not mere steeds, but comrades of battle, and are honored as kin. To ride with the Clan is to share one’s soul with a creature as fierce and noble as any warrior.",
	"In desperation, humanity developed atomic bombs, using all available plutonium to create two powerful weapons. These bombs succeeded in annihilating millions of monsters, but the victory was short-lived. The monsters' ability to reproduce quickly rendered the bombs ineffective, and humanity's strongest fortresses fell soon after. Agreements to live under the monsters were met with no mercy; humans were hunted, tortured, and enslaved. The last scientific observatories fell, marking the end of humanity's technological era. Only scattered settlements of a thousand or fewer remained, some striving to survive, others preserving the memory of their lost civilization.\n\nExcerpt From Arc 16",
	"Founded a mere thirty winters past, the Clan began as a fellowship of elite warriors, sworn not to crown or coin, but to the protection of the innocent and the slaying of all that is wicked. Though few in number, their might was vast, each member standing as a colossus among men. They rose swiftly, aided by skill, fortune, and blessings from powers both ancient and divine. \n\nWith each battle, their legend grew—until at last, they stood victorious over the Demon Lord himself. Thereafter, the Four Founders, weary from long campaigns, chose the path of peace. Some took to healing, others to teaching the arts of war and wisdom. Thus did they fade from the field of glory, their legacy carried by the next generation.",
	"A group of 'preserved' humans raised the new generation, who named this world Valemor. These humans escaped monster oppression and journeyed to the Arc ship to expand their population. Over 2,200 years, humanity built empires, rediscovered technology, and warred with the Drukdar, gaining control over 50% of the continents.\n\nExcerpt from the lost articles",
	"Now, in the absence of its founders, the Heroes' Guild is governed by a republican theocracy in the lands of Charkerean—once held in thrall by the demon king. Though the demon’s reign hath ended, whispers now rise of manaforged abominations and dark-hearted demons within the guild's own ranks. Despite these omens, the guild is oft contracted by great kingdoms to perform feats of war and diplomacy alike. Their coffers overflow with gold, yet some say the soul of the guild groweth cold.",
	"The Adventurer's Guilds were founded in 376 by a group of wealthy Frostborn nomads who were deeply connected to various trade routes, particularly those that passed through the diverse and perilous landscapes of Valemor. The guilds were initially created as a way to formalize and organize the growing number of mercenaries, monster hunters, and explorers who were providing essential services across the dominions, particularly in the aftermath of the Mana Surges that had fragmented the world.\n\nExcerpt from the Hero's archives",

	"The real political power of Adventurer’s Guilds lies in the Clans. While the guild masters and their conglomerates manage the broad organizational aspects of guild operations—overseeing entry-level guild members, handling regulatory matters, and providing logistical support such as lodging, supplies, and tavern subsidies—it is the Clans that often determine the success or failure of the guild. Clans are more than just skilled adventurers; they are power brokers, negotiators, and influencers in Valemor's intricate political web.\n\nKnowledge from Vulpin the Elf",

	"Certain families of Terran can also use the element of electricity, an ability exclusive to the Terrans, as well as a combat trance. Where they use mana to increase the adrenaline in their systems and copy its effects without going into mindless rage. This makes their warriors the best suited for combat and being quick, decisive decision makers in diplomatic relations.\n\nLore",
	"Oft do we embrace death, thinking it bringeth peace—yet lo, thou livest still, though pain be thy companion.",
	"Thou art wounded, and to feign strength is no cure for grief.",
	"This burden thou bearest is not from battle lost alone. Deeper wounds trouble thy spirit.",
	"Though thou fleest from the world, know this: it shall await thy return.",
	"We see thy weariness. Rest if thou must, but surrender not thy flame.",
	"Thou hast come far—do not scorn thyself for enduring thus.",
	"To fall is no shame. 'Tis in the rising that we forge our legend.",
	"Thou art more than thy darkest days. Hold fast to that truth.",
	"Breathe, weary soul. Let the world wait whilst thou mend thy heart.",
	"To need pause is no weakness—even the greatest of heroes must rest.",
	"In the deepest night, remember this: there was a reason thou began thy journey.",
	"The Verdent people are a deeply spiritual race, closely attuned to nature. They are the caretakers of the land, managing vast farms, producing medicine, and fostering agricultural growth. Their expertise in natural magic allows them to heal the land and people alike. Peaceful but fiercely protective of their land, they play an essential role in ensuring the survival of human civilization.\n\nLore"
]


func _ready():
	randomize()
	flavorinfo.text = flavor_texts[randi() % flavor_texts.size()]

	AudioManager.fade_out_music()
	AudioManager.play_music(preload("res://assets/Music/Beru_vs_S-Rank_Hunters_OPME.mp3"))

	_start_fade_loop()


func _start_fade_loop():
	var next_index = (current_color_index + 1) % fade_colors.size()
	var from_color = fade_colors[current_color_index]
	var to_color = fade_colors[next_index]

	background.modulate = from_color

	var tween = get_tree().create_tween()
	tween.tween_property(background, "modulate", to_color, 3.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "_on_fade_complete"))

	current_color_index = next_index


func _on_fade_complete():
	_start_fade_loop()


func _on_button_pressed():
	OS.shell_open("https://www.glenvilledixonjr.com")


func _on_exitbutton_pressed() -> void:
	get_tree().quit()


func _on_main_menu_pressed() -> void:
	TransitionManager.transition(0.5)
	await TransitionManager.on_transition_finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
