;Wrapper for Famitone2
.export FamiToneInit,FamiToneMusicPlay,FamiToneUpdate, FamiToneMusicStop, FamiToneMusicPause
.export FamiToneSfxInit,FamiToneSfxPlay
.export MusicData, SfxData

.segment "ZEROPAGE"

FT_TEMP:  .res 3

.segment "MUSICDATA"
FT_BASE_ADR:   .res 256

FT_DPCM_OFF=$c000
FT_SFX_STREAMS=2

FT_DPCM_ENABLE=$00
FT_SFX_ENABLE=$01
FT_THREAD=$01

FT_PAL_SUPPORT=$00
FT_NTSC_SUPPORT=$01

.segment "RODATA"
MusicData:
    .include "../data/music.s"
SfxData:
    .include "../data/sfx.s"

.segment "CODE"

.include "../lib/famitone2.s"
