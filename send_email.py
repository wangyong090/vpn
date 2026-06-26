#!/usr/bin/env python3
"""
BPB Panel 配置指南邮件发送脚本
通过 QQ 邮箱 SMTP 发送邮件（带附件）
"""

import smtplib
import sys
import os
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
from email.header import Header


def send_email(smtp_server, smtp_port, sender_email, auth_code,
               receiver_email, subject, body, attachment_path=None):
    """
    发送邮件（支持附件）

    Args:
        smtp_server: SMTP 服务器地址
        smtp_port: SMTP 端口（SSL）
        sender_email: 发件人邮箱
        auth_code: 授权码（不是登录密码）
        receiver_email: 收件人邮箱
        subject: 邮件主题
        body: 邮件正文
        attachment_path: 附件路径（可选）

    Returns:
        bool: 是否发送成功
    """
    try:
        msg = MIMEMultipart()
        msg['From'] = Header(sender_email)
        msg['To'] = Header(receiver_email)
        msg['Subject'] = Header(subject, 'utf-8')

        msg.attach(MIMEText(body, 'plain', 'utf-8'))

        # 添加附件
        if attachment_path and os.path.exists(attachment_path):
            filename = os.path.basename(attachment_path)
            with open(attachment_path, 'rb') as f:
                part = MIMEBase('application', 'octet-stream')
                part.set_payload(f.read())
            encoders.encode_base64(part)
            part.add_header(
                'Content-Disposition',
                f'attachment; filename="{filename}"'
            )
            msg.attach(part)
            print(f"[INFO] 已添加附件: {filename}")

        print(f"[INFO] 正在连接 SMTP 服务器: {smtp_server}:{smtp_port}")
        server = smtplib.SMTP_SSL(smtp_server, smtp_port)
        server.ehlo()
        print(f"[INFO] 正在登录: {sender_email}")
        server.login(sender_email, auth_code)

        print(f"[INFO] 正在发送邮件到: {receiver_email}")
        server.sendmail(sender_email, [receiver_email], msg.as_string())
        server.quit()

        print("[OK] 邮件发送成功！")
        return True

    except smtplib.SMTPAuthenticationError as e:
        print(f"[ERR] 认证失败，请检查授权码是否正确")
        print(f"[ERR] 错误信息: {e}")
        return False
    except smtplib.SMTPException as e:
        print(f"[ERR] SMTP 错误: {e}")
        return False
    except Exception as e:
        print(f"[ERR] 发送失败: {e}")
        return False


def main():
    print("=" * 50)
    print("  BPB Panel 配置指南 - 邮件发送工具")
    print("=" * 50)
    print()

    # QQ 邮箱 SMTP 配置
    smtp_server = "smtp.qq.com"
    smtp_port = 465

    # 收件人
    receiver_email = "19448063@qq.com"
    print(f"[INFO] 收件人: {receiver_email}")
    print()

    # 发件人配置 - 从环境变量读取或提示用户输入
    sender_email = os.environ.get("QQ_EMAIL", "").strip()
    auth_code = os.environ.get("QQ_AUTH_CODE", "").strip()

    if not sender_email:
        sender_email = input("请输入发件人 QQ 邮箱: ").strip()

    if not auth_code:
        import getpass
        auth_code = getpass.getpass("请输入 QQ 邮箱授权码（不是登录密码）: ").strip()

    if not sender_email or not auth_code:
        print("[ERR] 邮箱和授权码不能为空")
        sys.exit(1)

    # 邮件内容
    subject = "BPB Worker Panel 完整部署配置指南"
    body = """您好！

附件是 BPB Worker Panel 的完整部署与配置指南。

文档包含以下内容：
- 项目概述
- 部署步骤（手动部署 / Wrangler CLI 部署）
- KV 存储配置
- 环境变量配置
- 验证与首次使用
- 高级配置
- 常见问题解答
- 配置信息汇总表

请妥善保管您的 UUID 和密码等配置信息。

祝使用愉快！

---
本文档由自动化脚本生成
BPB Panel v4.1.3
"""

    # 附件路径
    attachment_path = "/workspace/BPB_Panel_部署配置指南.md"

    print()
    print("[INFO] 邮件主题:", subject)
    print("[INFO] 附件文件:", attachment_path)
    print()

    # 发送邮件
    success = send_email(
        smtp_server=smtp_server,
        smtp_port=smtp_port,
        sender_email=sender_email,
        auth_code=auth_code,
        receiver_email=receiver_email,
        subject=subject,
        body=body,
        attachment_path=attachment_path
    )

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
