/*
 * SPDX-FileCopyrightText: 2025 Davide De Rosa
 *
 * SPDX-License-Identifier: GPL-3.0
 */

#include <jni.h>
#include <assert.h>
#include <android/log.h>
#include <stdio.h>
#include <stdlib.h>
#include "vpn.h"

#define LOG_TAG "Passepartout"

static JavaVM *jvm = NULL;

JNIEXPORT jint JNICALL
JNI_OnLoad(JavaVM* localVM, void* reserved) {
    jvm = localVM;
    return JNI_VERSION_1_6;
}

// This must match Partout pp_tun tun_android.c
typedef struct {
    int fd;
} vpn_impl;

void vpn_test_callback() {
    __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "vpn_test_callback() was properly called!");
}

void vpn_test_working_wrapper(void *jniRef) {
    JNIEnv *env;
    (*jvm)->AttachCurrentThread(jvm, &env, NULL);
    jclass cls = (*env)->GetObjectClass(env, jniRef);
    jmethodID testWorkingMethod = (*env)->GetMethodID(
        env, cls, "testWorking", "()V"
    );
    (*env)->CallVoidMethod(env, jniRef, testWorkingMethod);
}

void *vpn_set_tunnel(void *jniRef, const partout_tun_ctrl_info *info) {
    assert(jniRef);
    __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "vpn_set_tunnel()");

    // FIXME: #188/partout, info must include remote endpoint, remote fd, and modules
    const int remoteFd = info->remote_fd;

    // Call VpnWrapper.build(), returns optional fd (Int?)
    JNIEnv *env;
    (*jvm)->AttachCurrentThread(jvm, &env, NULL);
    jclass cls = (*env)->GetObjectClass(env, jniRef);
    jmethodID buildMethod = (*env)->GetMethodID(env, cls, "build", "(I)Ljava/lang/Integer;");
    jobject fdObj = (*env)->CallObjectMethod(env, jniRef, buildMethod, remoteFd);
    if (fdObj == NULL) {
        return NULL;
    }
    jclass integerClass = (*env)->FindClass(env, "java/lang/Integer");
    jmethodID intValueMethod = (*env)->GetMethodID(env, integerClass, "intValue", "()I");
    const jint fd = (*env)->CallIntMethod(env, fdObj, intValueMethod);
    (*env)->DeleteLocalRef(env, integerClass);
    (*env)->DeleteLocalRef(env, fdObj);

    // Return the tunImpl for VirtualTunnelInterface in Partout
    vpn_impl *impl = malloc(sizeof(*impl));
    impl->fd = fd;
    return impl;
}

void vpn_clear_tunnel(void *jniRef, void *tunImpl) {
    assert(jniRef && tunImpl);
    __android_log_print(ANDROID_LOG_INFO, LOG_TAG, "vpn_clear_tunnel()");

    // Release the tunImpl allocated in set_tunnel
    vpn_impl *impl = tunImpl;
    // Do not close impl->fd, VpnWrapper.close() will take care
    free(impl);

    // Call VpnWrapper.close()
    JNIEnv *env;
    (*jvm)->AttachCurrentThread(jvm, &env, NULL);
    jclass cls = (*env)->GetObjectClass(env, jniRef);
    jmethodID closeMethod = (*env)->GetMethodID(env, cls, "close", "()V");
    (*env)->CallVoidMethod(env, jniRef, closeMethod);
}
