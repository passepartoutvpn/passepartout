// SPDX-FileCopyrightText: 2025 Davide De Rosa
//
// SPDX-License-Identifier: GPL-3.0

#include <jni.h>
#include <stdlib.h>
#include "partout.h"

JNIEXPORT jstring JNICALL
Java_com_algoritmico_passepartout_NativeWrapper_partoutVersion(JNIEnv *env, jobject thiz) {
    const char *msg = partout_version();
    jstring jmsg = (*env)->NewStringUTF(env, msg);
    free((char *)msg);
    return jmsg;
}
