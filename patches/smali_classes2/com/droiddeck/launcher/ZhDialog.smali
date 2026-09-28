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
    .locals 4

    sget-boolean v0, Lcom/droiddeck/launcher/ZhDialog;->shown:Z
    if-nez v0, :cond_return

    const/4 v0, 0x1
    sput-boolean v0, Lcom/droiddeck/launcher/ZhDialog;->shown:Z

    new-instance v0, Landroid/app/AlertDialog$Builder;
    invoke-direct {v0, p0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const-string v1, "汉化声明"
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    const-string v1, "汉化：mihsian77\n\n仅供学习交流使用，请勿用于商业用途。\n点击任意区域关闭。"
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    # 无按钮，点击弹窗外部或返回键即可关闭
    const/4 v1, 0x1
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog$Builder;->setCancelable(Z)Landroid/app/AlertDialog$Builder;

    invoke-virtual {v0}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;
    move-result-object v0

    # 设置点击外部区域关闭
    const/4 v1, 0x1
    invoke-virtual {v0, v1}, Landroid/app/AlertDialog;->setCanceledOnTouchOutside(Z)V

    invoke-virtual {v0}, Landroid/app/AlertDialog;->show()V

    :cond_return
    return-void
.end method
