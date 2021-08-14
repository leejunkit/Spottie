//
//  player_core.h
//  Spottie
//
//  Created by Lee Jun Kit on 14/8/21.
//

#ifndef player_core_h
#define player_core_h

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

void librespot_init(const void *user_data,
                    void (*event_callback)(const void*, uint8_t*, uintptr_t));


#endif /* player_core_h */
