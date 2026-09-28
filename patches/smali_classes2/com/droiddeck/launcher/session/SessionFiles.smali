.class public final Lcom/droiddeck/launcher/session/SessionFiles;
.super Ljava/lang/Object;
.source "SessionFiles.kt"


# annotations
.annotation system Ldalvik/annotation/SourceDebugExtension;
    value = "SMAP\nSessionFiles.kt\nKotlin\n*S Kotlin\n*F\n+ 1 SessionFiles.kt\ncom/droiddeck/launcher/session/SessionFiles\n+ 2 _Collections.kt\nkotlin/collections/CollectionsKt___CollectionsKt\n+ 3 _Arrays.kt\nkotlin/collections/ArraysKt___ArraysKt\n+ 4 fake.kt\nkotlin/jvm/internal/FakeKt\n*L\n1#1,174:1\n1557#2:175\n1628#2,3:176\n3829#3:179\n4344#3:180\n4345#3:182\n1#4:181\n*S KotlinDebug\n*F\n+ 1 SessionFiles.kt\ncom/droiddeck/launcher/session/SessionFiles\n*L\n81#1:175\n81#1:176,3\n88#1:179\n88#1:180\n88#1:182\n*E\n"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000(\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0010\u000e\n\u0002\u0008\u0003\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0008\u0002\u0008\u00c7\u0002\u0018\u00002\u00020\u0001B\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J\u0016\u0010\u0008\u001a\u00020\t2\u0006\u0010\n\u001a\u00020\u000b2\u0006\u0010\u000c\u001a\u00020\rJ\u000e\u0010\u000e\u001a\u00020\r2\u0006\u0010\n\u001a\u00020\u000bR\u000e\u0010\u0004\u001a\u00020\u0005X\u0082T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0005X\u0082T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0007\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000\u00a8\u0006\u000f"
    }
    d2 = {
        "Lcom/droiddeck/launcher/session/SessionFiles;",
        "",
        "<init>",
        "()V",
        "TAG",
        "",
        "NO_PAD_SWITCH",
        "DIRECTAUDIO_DIR",
        "stage",
        "",
        "context",
        "Landroid/content/Context;",
        "root",
        "Ljava/io/File;",
        "logDirectory",
        "app_release"
    }
    k = 0x1
    mv = {
        0x2,
        0x0,
        0x0
    }
    xi = 0x30
.end annotation


# static fields
.field public static final $stable:I = 0x0

.field public static final DIRECTAUDIO_DIR:Ljava/lang/String; = "usr/local/lib/directaudio"

.field public static final INSTANCE:Lcom/droiddeck/launcher/session/SessionFiles;

.field private static final NO_PAD_SWITCH:Ljava/lang/String; = "Download/droiddeck-no-pad"

.field private static final TAG:Ljava/lang/String; = "SessionFiles"


# direct methods
.method static constructor <clinit>()V
    .locals 1

    new-instance v0, Lcom/droiddeck/launcher/session/SessionFiles;

    invoke-direct {v0}, Lcom/droiddeck/launcher/session/SessionFiles;-><init>()V

    sput-object v0, Lcom/droiddeck/launcher/session/SessionFiles;->INSTANCE:Lcom/droiddeck/launcher/session/SessionFiles;

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    .line 11
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public final logDirectory(Landroid/content/Context;)Ljava/io/File;
    .locals 3

    const-string v0, "context"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 159
    invoke-static {}, Lcom/droiddeck/launcher/runtime/LinuxRuntime;->debugLogDir()Ljava/io/File;

    move-result-object v0

    .line 160
    invoke-virtual {v0}, Ljava/io/File;->isDirectory()Z

    move-result v1

    if-nez v1, :cond_0

    invoke-virtual {v0}, Ljava/io/File;->mkdirs()Z

    move-result v1

    if-eqz v1, :cond_2

    .line 161
    :cond_0
    new-instance v1, Ljava/io/File;

    const-string v2, ".writable"

    invoke-direct {v1, v0, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 163
    :try_start_0
    invoke-virtual {v1}, Ljava/io/File;->createNewFile()Z

    move-result v2

    if-nez v2, :cond_1

    invoke-virtual {v1}, Ljava/io/File;->isFile()Z

    move-result v2

    if-eqz v2, :cond_2

    .line 164
    :cond_1
    invoke-virtual {v1}, Ljava/io/File;->delete()Z

    .line 165
    invoke-static {v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-object v0

    .line 170
    :catch_0
    :cond_2
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " is not writable (storage permission?); logging to files/logs"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "SessionFiles"

    invoke-static {v1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 171
    new-instance v0, Ljava/io/File;

    invoke-virtual {p1}, Landroid/content/Context;->getFilesDir()Ljava/io/File;

    move-result-object p1

    const-string v1, "logs"

    invoke-direct {v0, p1, v1}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/io/File;->mkdirs()Z

    return-object v0
.end method

.method public final stage(Landroid/content/Context;Ljava/io/File;)V
    .locals 17

    move-object/from16 v1, p2

    const-string v0, "context"

    move-object/from16 v2, p1

    invoke-static {v2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "root"

    invoke-static {v1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const/16 v0, 0x17

    .line 28
    new-array v3, v0, [Lkotlin/Pair;

    const-string v0, "libblsession.so"

    const-string v4, "usr/local/lib/libblsession.so"

    invoke-static {v0, v4}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/4 v4, 0x0

    aput-object v0, v3, v4

    .line 29
    const-string v0, "libfakeinput.so"

    const-string v5, "usr/local/lib/libfakeinput.so"

    invoke-static {v0, v5}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/4 v5, 0x1

    aput-object v0, v3, v5

    .line 30
    const-string v0, "usr/local/bin/bannerlator-session"

    invoke-static {v0, v0}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/4 v6, 0x2

    aput-object v0, v3, v6

    .line 31
    const-string v0, "usr/local/bin/bannerlator-steam-compat"

    invoke-static {v0, v0}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/4 v7, 0x3

    aput-object v0, v3, v7

    .line 32
    const-string v0, "usr/local/bin/bannerlator-steam-install"

    invoke-static {v0, v0}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/4 v8, 0x4

    aput-object v0, v3, v8

    .line 33
    const-string v0, "usr/local/bin/bannerlator-steam-library"

    invoke-static {v0, v0}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/4 v9, 0x5

    aput-object v0, v3, v9

    .line 34
    const-string v0, "usr/local/bin/bannerlator-seed-redists"

    invoke-static {v0, v0}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/4 v10, 0x6

    aput-object v0, v3, v10

    .line 35
    const-string v0, "usr/local/bin/bannerlator-proton-extra"

    invoke-static {v0, v0}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/4 v11, 0x7

    aput-object v0, v3, v11

    .line 36
    const-string v0, "usr/local/bin/bannerlator-netmanager"

    invoke-static {v0, v0}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/16 v12, 0x8

    aput-object v0, v3, v12

    .line 37
    const-string v0, "usr/local/bin/bannerlator-steam-launch"

    invoke-static {v0, v0}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/16 v12, 0x9

    aput-object v0, v3, v12

    .line 38
    const-string v0, "usr/local/bin/bannerlator-desktop-games"

    invoke-static {v0, v0}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/16 v12, 0xa

    aput-object v0, v3, v12

    .line 39
    const-string v0, "usr/local/bin/bannerlator-steam-shim"

    invoke-static {v0, v0}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/16 v13, 0xb

    aput-object v0, v3, v13

    .line 40
    const-string v0, "usr/local/bin/bannerlator-steam-shortcuts"

    invoke-static {v0, v0}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/16 v13, 0xc

    aput-object v0, v3, v13

    .line 41
    const-string v0, "usr/local/bin/bannerlator-pad-defaults"

    const-string v13, "usr/local/bin/bannerlator-pad-defaults"

    invoke-static {v0, v13}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/16 v13, 0xd

    aput-object v0, v3, v13

    .line 44
    const-string v0, "usr/bin/steamos-update"

    const-string v13, "usr/bin/steamos-update"

    invoke-static {v0, v13}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/16 v13, 0xe

    aput-object v0, v3, v13

    .line 45
    const-string v0, "usr/bin/steamos-select-branch"

    const-string v13, "usr/bin/steamos-select-branch"

    invoke-static {v0, v13}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/16 v13, 0xf

    aput-object v0, v3, v13

    .line 46
    const-string v0, "usr/bin/jupiter-biosupdate"

    const-string v13, "usr/bin/jupiter-biosupdate"

    invoke-static {v0, v13}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/16 v13, 0x10

    aput-object v0, v3, v13

    .line 47
    const-string v0, "usr/bin/steamos-polkit-helpers/steamos-priv-write"

    const-string v13, "usr/bin/steamos-polkit-helpers/steamos-priv-write"

    invoke-static {v0, v13}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/16 v13, 0x11

    aput-object v0, v3, v13

    .line 48
    const-string v0, "usr/bin/steamos-polkit-helpers/steamos-set-timezone"

    const-string v13, "usr/bin/steamos-polkit-helpers/steamos-set-timezone"

    invoke-static {v0, v13}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/16 v13, 0x12

    aput-object v0, v3, v13

    .line 51
    const-string v0, "usr/bin/steamos-polkit-helpers/steamos-update"

    const-string v13, "usr/bin/steamos-polkit-helpers/steamos-update"

    invoke-static {v0, v13}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/16 v13, 0x13

    aput-object v0, v3, v13

    .line 52
    const-string v0, "usr/bin/steamos-polkit-helpers/steamos-select-branch"

    const-string v13, "usr/bin/steamos-polkit-helpers/steamos-select-branch"

    invoke-static {v0, v13}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/16 v13, 0x14

    aput-object v0, v3, v13

    .line 53
    const-string v0, "usr/bin/steamos-polkit-helpers/jupiter-biosupdate"

    const-string v13, "usr/bin/steamos-polkit-helpers/jupiter-biosupdate"

    invoke-static {v0, v13}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/16 v13, 0x15

    aput-object v0, v3, v13

    .line 54
    const-string v0, "zh-overlay.tar.gz"

    const-string v13, "usr/local/zh-overlay.tar.gz"

    invoke-static {v0, v13}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    const/16 v13, 0x16

    aput-object v0, v3, v13

    .line 59
    new-array v13, v11, [Lkotlin/Pair;

    const-string v0, "usr/local/bin/droiddeck-desktop"

    const-string v14, "usr/local/bin/droiddeck-desktop"

    invoke-static {v0, v14}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    aput-object v0, v13, v4

    .line 61
    const-string v0, "usr/local/bin/droiddeck-gpu"

    const-string v14, "usr/local/bin/droiddeck-gpu"

    invoke-static {v0, v14}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    aput-object v0, v13, v5

    .line 62
    const-string v0, "usr/local/bin/droiddeck-desktop-gpu"

    const-string v14, "usr/local/bin/droiddeck-desktop-gpu"

    invoke-static {v0, v14}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    aput-object v0, v13, v6

    .line 63
    const-string v0, "etc/xdg/labwc/autostart"

    const-string v14, "etc/xdg/labwc/autostart"

    invoke-static {v0, v14}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    aput-object v0, v13, v7

    .line 64
    const-string v0, "etc/xdg/labwc/rc.xml"

    const-string v14, "etc/xdg/labwc/rc.xml"

    invoke-static {v0, v14}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    aput-object v0, v13, v8

    .line 65
    const-string v0, "etc/xdg/lxqt/panel.conf"

    const-string v14, "etc/xdg/lxqt/panel.conf"

    invoke-static {v0, v14}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    aput-object v0, v13, v9

    .line 66
    const-string v0, "usr/lib/firefox/defaults/pref/droiddeck.js"

    const-string v14, "usr/lib/firefox/defaults/pref/droiddeck.js"

    invoke-static {v0, v14}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v0

    aput-object v0, v13, v10

    .line 74
    new-array v0, v11, [Ljava/lang/String;

    const-string v11, "usr/local/bin/mangoapp"

    aput-object v11, v0, v4

    .line 75
    const-string v11, "usr/local/lib/mangoapp/mangoapp"

    aput-object v11, v0, v5

    .line 76
    const-string v11, "usr/local/lib/mangoapp/libfmt.so.10"

    aput-object v11, v0, v6

    .line 77
    const-string v11, "usr/local/lib/mangoapp/libspdlog.so.1.13"

    aput-object v11, v0, v7

    .line 78
    const-string v11, "usr/local/lib/mangoapp/libglfw.so.3"

    aput-object v11, v0, v8

    .line 79
    const-string v8, "usr/local/lib/mangoapp/libtraceevent.so.1"

    aput-object v8, v0, v9

    .line 80
    const-string v8, "usr/local/lib/mangoapp/libtracefs.so.1"

    aput-object v8, v0, v10

    .line 73
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    check-cast v0, Ljava/lang/Iterable;

    .line 175
    new-instance v8, Ljava/util/ArrayList;

    invoke-static {v0, v12}, Lkotlin/collections/CollectionsKt;->collectionSizeOrDefault(Ljava/lang/Iterable;I)I

    move-result v9

    invoke-direct {v8, v9}, Ljava/util/ArrayList;-><init>(I)V

    check-cast v8, Ljava/util/Collection;

    .line 176
    invoke-interface {v0}, Ljava/lang/Iterable;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v9

    if-eqz v9, :cond_0

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v9

    .line 177
    check-cast v9, Ljava/lang/String;

    .line 81
    invoke-static {v9, v9}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v9

    .line 177
    invoke-interface {v8, v9}, Ljava/util/Collection;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 178
    :cond_0
    check-cast v8, Ljava/util/List;

    .line 83
    new-instance v0, Ljava/io/File;

    const-string v9, "usr/bin/labwc"

    invoke-direct {v0, v1, v9}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/io/File;->isFile()Z

    move-result v0

    if-eqz v0, :cond_1

    .line 84
    new-array v0, v5, [Lkotlin/Pair;

    const-string v9, "usr/local/lib/droiddeck-wlroots/libwlroots-0.20.so"

    const-string v10, "usr/local/lib/droiddeck-wlroots/libwlroots-0.20.so"

    invoke-static {v9, v10}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v9

    aput-object v9, v0, v4

    goto :goto_1

    .line 85
    :cond_1
    new-array v0, v4, [Lkotlin/Pair;

    .line 87
    :goto_1
    new-array v9, v5, [Lkotlin/Pair;

    const-string v10, "usr/local/bin/gamescope"

    const-string v11, "usr/local/bin/gamescope"

    invoke-static {v10, v11}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v10

    aput-object v10, v9, v4

    .line 86
    invoke-static {v9, v0}, Lkotlin/collections/ArraysKt;->plus([Ljava/lang/Object;[Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object v0

    .line 88
    check-cast v8, Ljava/util/Collection;

    .line 86
    invoke-static {v0, v8}, Lkotlin/collections/ArraysKt;->plus([Ljava/lang/Object;Ljava/util/Collection;)[Ljava/lang/Object;

    move-result-object v8

    .line 179
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    move-object v9, v0

    check-cast v9, Ljava/util/Collection;

    .line 180
    array-length v10, v8

    move v11, v4

    :goto_2
    const/4 v12, 0x0

    if-ge v11, v10, :cond_5

    aget-object v14, v8, v11

    move-object v0, v14

    check-cast v0, Lkotlin/Pair;

    .line 88
    invoke-virtual {v0}, Lkotlin/Pair;->component1()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    const/16 v15, 0x2f

    .line 89
    invoke-static {v0, v15, v12, v6, v12}, Lkotlin/text/StringsKt;->substringBeforeLast$default(Ljava/lang/String;CLjava/lang/String;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v15

    .line 90
    :try_start_0
    sget-object v16, Lkotlin/Result;->Companion:Lkotlin/Result$Companion;

    invoke-virtual/range {p1 .. p1}, Landroid/content/Context;->getAssets()Landroid/content/res/AssetManager;

    move-result-object v7

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "linuxfs/"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v7, v4}, Landroid/content/res/AssetManager;->list(Ljava/lang/String;)[Ljava/lang/String;

    move-result-object v4

    if-eqz v4, :cond_2

    const/16 v5, 0x2f

    invoke-static {v0, v5, v12, v6, v12}, Lkotlin/text/StringsKt;->substringAfterLast$default(Ljava/lang/String;CLjava/lang/String;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    invoke-static {v4, v0}, Lkotlin/collections/ArraysKt;->contains([Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0

    const/4 v4, 0x1

    if-ne v0, v4, :cond_2

    const/4 v0, 0x1

    goto :goto_3

    :cond_2
    const/4 v0, 0x0

    :goto_3
    invoke-static {v0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v0

    invoke-static {v0}, Lkotlin/Result;->constructor-impl(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_4

    :catchall_0
    move-exception v0

    sget-object v4, Lkotlin/Result;->Companion:Lkotlin/Result$Companion;

    invoke-static {v0}, Lkotlin/ResultKt;->createFailure(Ljava/lang/Throwable;)Ljava/lang/Object;

    move-result-object v0

    invoke-static {v0}, Lkotlin/Result;->constructor-impl(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    :goto_4
    const/4 v4, 0x0

    invoke-static {v4}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v5

    invoke-static {v0}, Lkotlin/Result;->isFailure-impl(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_3

    move-object v0, v5

    :cond_3
    check-cast v0, Ljava/lang/Boolean;

    invoke-virtual {v0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v0

    if-eqz v0, :cond_4

    .line 180
    invoke-interface {v9, v14}, Ljava/util/Collection;->add(Ljava/lang/Object;)Z

    :cond_4
    add-int/lit8 v11, v11, 0x1

    const/4 v4, 0x0

    const/4 v5, 0x1

    const/4 v7, 0x3

    goto :goto_2

    .line 182
    :cond_5
    check-cast v9, Ljava/util/List;

    .line 92
    new-instance v0, Ljava/io/File;

    const-string v4, "usr/bin/labwc"

    invoke-direct {v0, v1, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/io/File;->isFile()Z

    move-result v0

    if-eqz v0, :cond_6

    invoke-static {v3, v13}, Lkotlin/collections/ArraysKt;->plus([Ljava/lang/Object;[Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object v0

    move-object v3, v0

    check-cast v3, [Lkotlin/Pair;

    :cond_6
    check-cast v9, Ljava/util/Collection;

    invoke-static {v3, v9}, Lkotlin/collections/ArraysKt;->plus([Ljava/lang/Object;Ljava/util/Collection;)[Ljava/lang/Object;

    move-result-object v0

    move-object v3, v0

    check-cast v3, [Lkotlin/Pair;

    .line 93
    array-length v4, v3

    const/4 v5, 0x0

    :goto_5
    const-string v7, "SessionFiles"

    if-ge v5, v4, :cond_b

    aget-object v0, v3, v5

    invoke-virtual {v0}, Lkotlin/Pair;->component1()Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/lang/String;

    invoke-virtual {v0}, Lkotlin/Pair;->component2()Ljava/lang/Object;

    move-result-object v0

    move-object v9, v0

    check-cast v9, Ljava/lang/String;

    .line 94
    new-instance v0, Ljava/io/File;

    invoke-direct {v0, v1, v9}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 95
    new-instance v10, Ljava/io/File;

    invoke-virtual {v0}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v11

    invoke-virtual {v0}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v13

    new-instance v14, Ljava/lang/StringBuilder;

    invoke-direct {v14}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v14, v13}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v13

    const-string v14, ".staged"

    invoke-virtual {v13, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v13

    invoke-virtual {v13}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v13

    invoke-direct {v10, v11, v13}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 98
    :try_start_1
    invoke-virtual {v0}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v11

    if-eqz v11, :cond_7

    invoke-virtual {v11}, Ljava/io/File;->mkdirs()Z

    .line 99
    :cond_7
    invoke-virtual/range {p1 .. p1}, Landroid/content/Context;->getAssets()Landroid/content/res/AssetManager;

    move-result-object v11

    new-instance v13, Ljava/lang/StringBuilder;

    invoke-direct {v13}, Ljava/lang/StringBuilder;-><init>()V

    const-string v14, "linuxfs/"

    invoke-virtual {v13, v14}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v13

    invoke-virtual {v13, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v11, v8}, Landroid/content/res/AssetManager;->open(Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object v8

    check-cast v8, Ljava/io/Closeable;
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_5

    :try_start_2
    move-object v11, v8

    check-cast v11, Ljava/io/InputStream;

    new-instance v13, Ljava/io/FileOutputStream;

    .line 100
    invoke-direct {v13, v10}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V

    check-cast v13, Ljava/io/Closeable;
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_3

    :try_start_3
    move-object v14, v13

    check-cast v14, Ljava/io/FileOutputStream;

    check-cast v14, Ljava/io/OutputStream;

    invoke-static {v11, v14}, Lcom/droiddeck/launcher/core/FileUtils;->copy(Ljava/io/InputStream;Ljava/io/OutputStream;)V

    sget-object v11, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    :try_start_4
    invoke-static {v13, v12}, Lkotlin/io/CloseableKt;->closeFinally(Ljava/io/Closeable;Ljava/lang/Throwable;)V

    .line 101
    sget-object v11, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_3

    .line 99
    :try_start_5
    invoke-static {v8, v12}, Lkotlin/io/CloseableKt;->closeFinally(Ljava/io/Closeable;Ljava/lang/Throwable;)V

    const/4 v8, 0x0

    const/4 v11, 0x1

    .line 102
    invoke-virtual {v10, v11, v8}, Ljava/io/File;->setExecutable(ZZ)Z

    move-result v13

    if-eqz v13, :cond_8

    invoke-virtual {v10, v0}, Ljava/io/File;->renameTo(Ljava/io/File;)Z

    move-result v0
    :try_end_5
    .catch Ljava/lang/Exception; {:try_start_5 .. :try_end_5} :catch_0
    .catchall {:try_start_5 .. :try_end_5} :catchall_5

    if-eqz v0, :cond_8

    const/4 v0, 0x1

    goto :goto_6

    :cond_8
    const/4 v0, 0x0

    :goto_6
    if-nez v0, :cond_9

    .line 106
    invoke-virtual {v10}, Ljava/io/File;->delete()Z

    goto :goto_7

    :catchall_1
    move-exception v0

    move-object v11, v0

    .line 100
    :try_start_6
    throw v11
    :try_end_6
    .catchall {:try_start_6 .. :try_end_6} :catchall_2

    :catchall_2
    move-exception v0

    move-object v14, v0

    :try_start_7
    invoke-static {v13, v11}, Lkotlin/io/CloseableKt;->closeFinally(Ljava/io/Closeable;Ljava/lang/Throwable;)V

    throw v14
    :try_end_7
    .catchall {:try_start_7 .. :try_end_7} :catchall_3

    :catchall_3
    move-exception v0

    move-object v11, v0

    .line 99
    :try_start_8
    throw v11
    :try_end_8
    .catchall {:try_start_8 .. :try_end_8} :catchall_4

    :catchall_4
    move-exception v0

    move-object v13, v0

    :try_start_9
    invoke-static {v8, v11}, Lkotlin/io/CloseableKt;->closeFinally(Ljava/io/Closeable;Ljava/lang/Throwable;)V

    throw v13
    :try_end_9
    .catch Ljava/lang/Exception; {:try_start_9 .. :try_end_9} :catch_0
    .catchall {:try_start_9 .. :try_end_9} :catchall_5

    :catchall_5
    move-exception v0

    goto :goto_8

    :catch_0
    move-exception v0

    .line 104
    :try_start_a
    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    const-string v11, "could not stage "

    invoke-virtual {v8, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    check-cast v0, Ljava/lang/Throwable;

    invoke-static {v7, v8, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :try_end_a
    .catchall {:try_start_a .. :try_end_a} :catchall_5

    .line 106
    invoke-virtual {v10}, Ljava/io/File;->delete()Z

    const/4 v0, 0x0

    :cond_9
    :goto_7
    if-nez v0, :cond_a

    .line 108
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v0, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v8, " NOT staged"

    invoke-virtual {v0, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v7, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_a
    add-int/lit8 v5, v5, 0x1

    goto/16 :goto_5

    .line 106
    :goto_8
    invoke-virtual {v10}, Ljava/io/File;->delete()Z

    throw v0

    :cond_b
    const/4 v3, 0x3

    .line 114
    new-array v4, v3, [Ljava/lang/String;

    const-string v0, "aarch64-unix/winedirectaudio.so"

    const/4 v5, 0x0

    aput-object v0, v4, v5

    .line 115
    const-string v0, "aarch64-windows/winedirectaudio.drv"

    const/4 v5, 0x1

    aput-object v0, v4, v5

    .line 116
    const-string v0, "i386-windows/winedirectaudio.drv"

    aput-object v0, v4, v6

    const/4 v5, 0x0

    :goto_9
    if-ge v5, v3, :cond_10

    .line 118
    aget-object v6, v4, v5

    .line 119
    new-instance v0, Ljava/io/File;

    new-instance v8, Ljava/lang/StringBuilder;

    const-string v9, "usr/local/lib/directaudio/lib/wine/"

    invoke-direct {v8, v9}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v8, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-direct {v0, v1, v8}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 120
    new-instance v8, Ljava/io/File;

    invoke-virtual {v0}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v9

    invoke-virtual {v0}, Ljava/io/File;->getName()Ljava/lang/String;

    move-result-object v10

    new-instance v11, Ljava/lang/StringBuilder;

    invoke-direct {v11}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v11, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    const-string v11, ".staged"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    invoke-direct {v8, v9, v10}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 123
    :try_start_b
    invoke-virtual {v0}, Ljava/io/File;->getParentFile()Ljava/io/File;

    move-result-object v9

    if-eqz v9, :cond_c

    invoke-virtual {v9}, Ljava/io/File;->mkdirs()Z

    .line 124
    :cond_c
    invoke-virtual/range {p1 .. p1}, Landroid/content/Context;->getAssets()Landroid/content/res/AssetManager;

    move-result-object v9

    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    const-string v11, "directaudio/linux-wine11/"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    invoke-virtual {v9, v10}, Landroid/content/res/AssetManager;->open(Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object v9

    check-cast v9, Ljava/io/Closeable;
    :try_end_b
    .catch Ljava/lang/Exception; {:try_start_b .. :try_end_b} :catch_2
    .catchall {:try_start_b .. :try_end_b} :catchall_b

    :try_start_c
    move-object v10, v9

    check-cast v10, Ljava/io/InputStream;

    new-instance v11, Ljava/io/FileOutputStream;

    .line 125
    invoke-direct {v11, v8}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V

    check-cast v11, Ljava/io/Closeable;
    :try_end_c
    .catchall {:try_start_c .. :try_end_c} :catchall_9

    :try_start_d
    move-object v13, v11

    check-cast v13, Ljava/io/FileOutputStream;

    check-cast v13, Ljava/io/OutputStream;

    invoke-static {v10, v13}, Lcom/droiddeck/launcher/core/FileUtils;->copy(Ljava/io/InputStream;Ljava/io/OutputStream;)V

    sget-object v10, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;
    :try_end_d
    .catchall {:try_start_d .. :try_end_d} :catchall_6

    :try_start_e
    invoke-static {v11, v12}, Lkotlin/io/CloseableKt;->closeFinally(Ljava/io/Closeable;Ljava/lang/Throwable;)V

    .line 126
    sget-object v10, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;
    :try_end_e
    .catchall {:try_start_e .. :try_end_e} :catchall_9

    .line 124
    :try_start_f
    invoke-static {v9, v12}, Lkotlin/io/CloseableKt;->closeFinally(Ljava/io/Closeable;Ljava/lang/Throwable;)V
    :try_end_f
    .catch Ljava/lang/Exception; {:try_start_f .. :try_end_f} :catch_2
    .catchall {:try_start_f .. :try_end_f} :catchall_b

    const/4 v10, 0x0

    const/4 v13, 0x1

    .line 127
    :try_start_10
    invoke-virtual {v8, v13, v10}, Ljava/io/File;->setReadable(ZZ)Z

    move-result v9

    if-eqz v9, :cond_d

    invoke-virtual {v8, v0}, Ljava/io/File;->renameTo(Ljava/io/File;)Z

    move-result v0
    :try_end_10
    .catch Ljava/lang/Exception; {:try_start_10 .. :try_end_10} :catch_1
    .catchall {:try_start_10 .. :try_end_10} :catchall_b

    if-eqz v0, :cond_d

    move v0, v13

    goto :goto_a

    :cond_d
    move v0, v10

    :goto_a
    if-nez v0, :cond_e

    .line 131
    invoke-virtual {v8}, Ljava/io/File;->delete()Z

    goto :goto_d

    :catchall_6
    move-exception v0

    const/4 v10, 0x0

    const/4 v13, 0x1

    move-object v14, v0

    .line 125
    :try_start_11
    throw v14
    :try_end_11
    .catchall {:try_start_11 .. :try_end_11} :catchall_7

    :catchall_7
    move-exception v0

    move-object v15, v0

    :try_start_12
    invoke-static {v11, v14}, Lkotlin/io/CloseableKt;->closeFinally(Ljava/io/Closeable;Ljava/lang/Throwable;)V

    throw v15
    :try_end_12
    .catchall {:try_start_12 .. :try_end_12} :catchall_8

    :catchall_8
    move-exception v0

    goto :goto_b

    :catchall_9
    move-exception v0

    const/4 v10, 0x0

    const/4 v13, 0x1

    :goto_b
    move-object v11, v0

    .line 124
    :try_start_13
    throw v11
    :try_end_13
    .catchall {:try_start_13 .. :try_end_13} :catchall_a

    :catchall_a
    move-exception v0

    move-object v14, v0

    :try_start_14
    invoke-static {v9, v11}, Lkotlin/io/CloseableKt;->closeFinally(Ljava/io/Closeable;Ljava/lang/Throwable;)V

    throw v14
    :try_end_14
    .catch Ljava/lang/Exception; {:try_start_14 .. :try_end_14} :catch_1
    .catchall {:try_start_14 .. :try_end_14} :catchall_b

    :catch_1
    move-exception v0

    goto :goto_c

    :catchall_b
    move-exception v0

    goto :goto_e

    :catch_2
    move-exception v0

    const/4 v10, 0x0

    const/4 v13, 0x1

    .line 129
    :goto_c
    :try_start_15
    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    const-string v11, "could not stage DirectAudio "

    invoke-virtual {v9, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v9

    check-cast v0, Ljava/lang/Throwable;

    invoke-static {v7, v9, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :try_end_15
    .catchall {:try_start_15 .. :try_end_15} :catchall_b

    .line 131
    invoke-virtual {v8}, Ljava/io/File;->delete()Z

    move v0, v10

    :cond_e
    :goto_d
    if-nez v0, :cond_f

    .line 133
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v8, "DirectAudio "

    invoke-direct {v0, v8}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v6, " NOT staged"

    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v7, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_f
    add-int/lit8 v5, v5, 0x1

    goto/16 :goto_9

    .line 131
    :goto_e
    invoke-virtual {v8}, Ljava/io/File;->delete()Z

    throw v0

    .line 138
    :cond_10
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v2, "/usr/local/lib/libblsession.so\n"

    invoke-direct {v0, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 139
    new-instance v2, Ljava/io/File;

    invoke-static {}, Landroid/os/Environment;->getExternalStorageDirectory()Ljava/io/File;

    move-result-object v3

    const-string v4, "Download/droiddeck-no-pad"

    invoke-direct {v2, v3, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    move-result v2

    if-nez v2, :cond_11

    .line 140
    const-string v2, "/usr/local/lib/libfakeinput.so\n"

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 142
    :cond_11
    new-instance v2, Ljava/io/File;

    const-string v3, "etc"

    invoke-direct {v2, v1, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v2}, Ljava/io/File;->mkdirs()Z

    .line 143
    new-instance v1, Ljava/io/File;

    const-string v3, "ld.so.preload.staged"

    invoke-direct {v1, v2, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 144
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Lcom/droiddeck/launcher/core/FileUtils;->writeString(Ljava/io/File;Ljava/lang/String;)Z

    move-result v0

    if-eqz v0, :cond_12

    .line 145
    new-instance v0, Ljava/io/File;

    const-string v3, "ld.so.preload"

    invoke-direct {v0, v2, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/io/File;->renameTo(Ljava/io/File;)Z

    move-result v0

    if-nez v0, :cond_13

    .line 146
    :cond_12
    invoke-virtual {v1}, Ljava/io/File;->delete()Z

    .line 147
    const-string v0, "could not write ld.so.preload"

    invoke-static {v7, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    :cond_13
    return-void
.end method
