.class public Lcom/droiddeck/launcher/ZhDialog;
.super Ljava/lang/Object;
.source "ZhDialog.kt"

.field private static shown:Z

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public static show(Landroid/content/Context;)V
    .locals 5

    sget-boolean v0, Lcom/droiddeck/launcher/ZhDialog;->shown:Z
    if-nez v0, :cond_return

    const/4 v0, 0x1
    sput-boolean v0, Lcom/droiddeck/launcher/ZhDialog;->shown:Z

    new-instance v0, Landroid/app/AlertDialog$Builder;
    invoke-direct {v0, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const-string v1, "汉化声明"
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    const-string v1, "本应用由 DroidDeck-zh 项目汉化\n汉化来源：github.com/hao728/DroidDeck-zh\n\n本汉化版仅供学习交流使用，请勿用于商业用途。\n点击「访问仓库」可在浏览器中打开汉化项目主页。"
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    const-string v1, "确定"
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    const-string v1, "访问仓库"
    new-instance v2, Lcom/droiddeck/launcher/ZhDialog$UrlListener;
    invoke-direct {v2}, Lcom/droiddeck/launcher/ZhDialog$UrlListener;-><init>()V
    invoke-virtual {v0, v1, v2}, Landroid/app/AlertDialog$Builder;->setNeutralButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;
    move-result-object v0
    invoke-virtual {v0}, Landroid/app/AlertDialog;->show()V

    :cond_return
    return-void
.end method
