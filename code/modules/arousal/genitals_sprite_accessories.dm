/datum/sprite_accessory
	var/alt_aroused = FALSE //CIT CODE if this is TRUE, then the genitals will use an alternate icon_state when aroused.
	var/taur_icon //leave null if the genital doesn't have a taur counterpart.
	var/accepted_taurs = STYLE_HOOF_TAURIC|STYLE_PAW_TAURIC //Types that match with the accessory.
	var/feat_taur //the text string of the dna feature to check for those who want to opt out.
	var/taur_dimension_y = 32
	var/taur_dimension_x = 32

/*
 * This is an example of a penis object in the code.
 * The icon_state of the penis is structured as follows:
 * "penis_human_4_1_FRONT"
 * Where "human" is the type of the penis, "4" is the size stage of the penis, and "1" means it's the erect sprite, while "0" would be the soft one.
 * If the sprite is like this: "penis_human_4_s_1_FRONT", the extra "_s" means it's used by the default skintones (the list of default skin tones that "Albino, Caucasian, etc.").
 * Those "_s" sprites use a more pink-ish tone instead of white, to match the different default skin tones automatically,
 * while the icon states without the "_s" are used by the custom skin tone.
 * In the future, it would be best to solve this, as it creates useless duplicated icon states, and therefore heavier file sizes. 
 * It would be best to just have 1 set of icon states that apply themselves normally to both custom skin tone users and match default skin tone users, 
 * effectively removing the need of using the extra "_s". - Goku
 */

//DICKS,COCKS,PENISES,WHATEVER YOU WANT TO CALL THEM
/datum/sprite_accessory/penis
	icon = 'icons/obj/genitals/penis_onmob.dmi'
	name = "penis"			//the preview name of the accessory
	color_src = "cock_color"
	alt_aroused = TRUE
	feat_taur = "cock_taur"

/datum/sprite_accessory/penis/teshari
	icon_state = "taperedteshari"
	name = "Teshari"
	icon = 'modular_splurt/icons/obj/genitals/teshari_penis.dmi'

/datum/sprite_accessory/penis/human
	icon_state = "human"
	name = "Human"

/datum/sprite_accessory/penis/knotted
	icon_state = "knotted"
	name = "Knotted"
	taur_icon = 'icons/obj/genitals/taur_penis_onmob.dmi'
	taur_dimension_x = 64

/datum/sprite_accessory/penis/flared
	icon_state = "flared"
	name = "Flared"
	taur_icon = 'icons/obj/genitals/taur_penis_onmob.dmi'
	taur_dimension_x = 64

/datum/sprite_accessory/penis/barbknot
	icon_state = "barbknot"
	name = "Barbed, Knotted"

/datum/sprite_accessory/penis/tapered
	icon_state = "tapered"
	name = "Tapered"
	taur_icon = 'icons/obj/genitals/taur_penis_onmob.dmi'
	taur_dimension_x = 64

/datum/sprite_accessory/penis/tentacle
	icon_state = "tentacle"
	name = "Tentacled"

/datum/sprite_accessory/penis/hemi
	icon_state = "hemi"
	name = "Hemi"

/datum/sprite_accessory/penis/hemiknot
	icon_state = "hemiknot"
	name = "Knotted Hemi"

//Testicles
/datum/sprite_accessory/testicles
	icon = 'icons/obj/genitals/testicles_onmob.dmi'
	icon_state = "testicle"
	name = "testicle"		//the preview name of the accessory
	color_src = "balls_color"

/datum/sprite_accessory/testicles/single
	icon_state = "single"
	name = "Single" //Single as "single pair", for clarity.

/datum/sprite_accessory/testicles/hidden
	icon_state = "hidden"
	name = "Hidden" //not sure why these were missing, but I'm pretty certain people might want these.

//Vaginas
/datum/sprite_accessory/vagina
	icon = 'icons/obj/genitals/vagina_onmob.dmi'
	name = "vagina"
	color_src = "vag_color"
	alt_aroused = TRUE

/datum/sprite_accessory/vagina/human
	icon_state = "human"
	name = "Human"

/datum/sprite_accessory/vagina/tentacles
	icon_state = "tentacle"
	name = "Tentacle"

/datum/sprite_accessory/vagina/dentata
	icon_state = "dentata"
	name = "Dentata"

/datum/sprite_accessory/vagina/hairy
	icon_state = "hairy"
	name = "Hairy"
	alt_aroused = FALSE

/datum/sprite_accessory/vagina/spade
	icon_state = "spade"
	name = "Spade"
	alt_aroused = FALSE

/datum/sprite_accessory/vagina/furred
	icon_state = "furred"
	name = "Furred"
	alt_aroused = FALSE

/datum/sprite_accessory/vagina/gaping
	icon_state = "gaping"
	name = "Gaping"

//BREASTS BE HERE
/datum/sprite_accessory/breasts
	icon = 'icons/obj/genitals/breasts_onmob.dmi'
	name = "breasts"
	color_src = "breasts_color"

/datum/sprite_accessory/breasts/pair
	icon_state = "pair"
	name = "Pair"

/datum/sprite_accessory/breasts/quad
	icon_state = "quad"
	name = "Quad"

/datum/sprite_accessory/breasts/sextuple
	icon_state = "sextuple"
	name = "Sextuple"

//BUTT BE HERE
/datum/sprite_accessory/butt
	icon = 'icons/obj/genitals/butt_onmob.dmi'
	icon_state = "butt"
	name = "butt"
	color_src = "butt_color"

//there literally shouldn't be any other ass types besides one because that'd be weird, this is just here to keep things consistent for the genital system.
/datum/sprite_accessory/butt/pair
	icon_state = "pair"
	name = "Pair"
