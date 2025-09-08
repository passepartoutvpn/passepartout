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

    JNIEnv *env;
    (*jvm)->AttachCurrentThread(jvm, &env, NULL);

    // Build input array with remote fds
    jclass integerCls = (*env)->FindClass(env, "java/lang/Integer");
    jmethodID integerCtor = (*env)->GetMethodID(env, integerCls, "<init>", "(I)V");
    const jsize len = info->remote_fds_len;
    jobjectArray remoteFdsObj = (*env)->NewObjectArray(env, len, integerCls, NULL);
    for (jsize i = 0; i < len; i++) {
        jobject elem = (*env)->NewObject(env, integerCls, integerCtor, (jint)(info->remote_fds[i]));
        (*env)->SetObjectArrayElement(env, remoteFdsObj, i, elem);
        (*env)->DeleteLocalRef(env, elem);
    }

    // Call VpnWrapper.build(), returns optional fd (Int?)
    jclass cls = (*env)->GetObjectClass(env, jniRef);
    jmethodID buildMethod = (*env)->GetMethodID(env, cls, "build", "([Ljava/lang/Integer;)Ljava/lang/Integer;");
    jobject fdObj = (*env)->CallObjectMethod(env, jniRef, buildMethod, remoteFdsObj);
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

void vpn_configure_sockets(void *jniRef, const int *fds, const size_t fds_len) {
    JNIEnv *env;
    (*jvm)->AttachCurrentThread(jvm, &env, NULL);

    jclass integerCls = (*env)->FindClass(env, "java/lang/Integer");
    jmethodID integerCtor = (*env)->GetMethodID(env, integerCls, "<init>", "(I)V");
    jobjectArray fdsObj = (*env)->NewObjectArray(env, fds_len, integerCls, NULL);
    for (jsize i = 0; i < fds_len; i++) {
        jobject elem = (*env)->NewObject(env, integerCls, integerCtor, (jint)(fds[i]));
        (*env)->SetObjectArrayElement(env, fdsObj, i, elem);
        (*env)->DeleteLocalRef(env, elem);
    }

    // Call VpnWrapper.configureSockets()
    jclass cls = (*env)->GetObjectClass(env, jniRef);
    jmethodID cfgMethod = (*env)->GetMethodID(env, cls, "configureSockets", "([Ljava/lang/Integer;)V");
    (*env)->CallVoidMethod(env, jniRef, cfgMethod, fdsObj);
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
