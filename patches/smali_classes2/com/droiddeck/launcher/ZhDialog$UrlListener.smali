.class Lcom/droiddeck/launcher/ZhDialog$UrlListener;
.super Ljava/lang/Object;
.implements Landroid/content/DialogInterface$OnClickListener;
.source "ZhDialog.kt"

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 4

    check-cast p1, Landroid/app/Dialog;
    invoke-virtual {p1}, Landroid/app/Dialog;->getContext()Landroid/content/Context;
    move-result-object v0

    new-instance v1, Landroid/content/Intent;
    const-string v2, "android.intent.action.VIEW"
    const-string v3, "https://github.com/mihsian77/DroidDeck-zh"
    invoke-static {v3}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;
    move-result-object v3
    invoke-direct {v1, v2, v3}, Landroid/content/Intent;-><init>(Ljava/lang/String;Landroid/net/Uri;)V

    invoke-virtual {v0, v1}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    return-void
.end method
