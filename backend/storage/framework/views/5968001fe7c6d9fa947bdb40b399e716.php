<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment Confirmation - Invoice <?php echo e($invoice_number); ?></title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        .header {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            padding: 30px 20px;
            text-align: center;
        }
        .logo {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .title {
            font-size: 20px;
            margin: 0;
            font-weight: 600;
        }
        .content {
            padding: 30px;
        }
        .confirmation-box {
            background-color: #f0fdf4;
            border: 2px solid #10b981;
            border-radius: 8px;
            padding: 25px;
            text-align: center;
            margin-bottom: 25px;
        }
        .confirmation-icon {
            font-size: 48px;
            color: #10b981;
            margin-bottom: 15px;
        }
        .confirmation-title {
            font-size: 22px;
            font-weight: 700;
            color: #065f46;
            margin-bottom: 10px;
        }
        .amount-display {
            font-size: 32px;
            font-weight: 700;
            color: #065f46;
            margin: 15px 0;
        }
        .payment-details {
            background-color: #f8f9fa;
            border-radius: 6px;
            padding: 20px;
            margin-bottom: 25px;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
            padding-bottom: 12px;
            border-bottom: 1px solid #e9ecef;
        }
        .detail-row:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }
        .detail-label {
            color: #666;
            font-weight: 500;
        }
        .detail-value {
            font-weight: 600;
            color: #333;
        }
        .invoice-info {
            background-color: #f1f5f9;
            border-radius: 6px;
            padding: 20px;
            margin-bottom: 25px;
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }
        .info-label {
            color: #666;
            font-weight: 500;
        }
        .info-value {
            font-weight: 600;
            color: #333;
        }
        .receipt-note {
            background-color: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .footer {
            background-color: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #666;
            font-size: 14px;
            border-top: 1px solid #e9ecef;
        }
        .support-info {
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #e9ecef;
            color: #666;
            font-size: 14px;
        }
        .thank-you {
            text-align: center;
            font-size: 18px;
            color: #10b981;
            margin: 25px 0;
            font-weight: 600;
        }
        @media (max-width: 600px) {
            .content {
                padding: 20px;
            }
            .detail-row, .info-row {
                flex-direction: column;
            }
            .detail-value, .info-value {
                margin-top: 5px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">NexaTrace</div>
            <h1 class="title">Payment Confirmation</h1>
        </div>

        <div class="content">
            <p>Dear <?php echo e($to_name); ?>,</p>

            <div class="confirmation-box">
                <div class="confirmation-icon">✓</div>
                <div class="confirmation-title">Payment Successful</div>
                <div class="amount-display"><?php echo e($currency); ?> <?php echo e($payment_amount); ?></div>
                <p>Your payment has been processed successfully.</p>
            </div>

            <div class="payment-details">
                <div class="detail-row">
                    <span class="detail-label">Payment Date:</span>
                    <span class="detail-value"><?php echo e($payment_date); ?></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Payment Method:</span>
                    <span class="detail-value"><?php echo e($payment_method); ?></span>
                </div>
                <?php if(!empty($payment_reference)): ?>
                <div class="detail-row">
                    <span class="detail-label">Reference Number:</span>
                    <span class="detail-value"><?php echo e($payment_reference); ?></span>
                </div>
                <?php endif; ?>
                <?php if(!empty($receipt_number)): ?>
                <div class="detail-row">
                    <span class="detail-label">Receipt Number:</span>
                    <span class="detail-value"><?php echo e($receipt_number); ?></span>
                </div>
                <?php endif; ?>
            </div>

            <div class="invoice-info">
                <div class="info-row">
                    <span class="info-label">Invoice Number:</span>
                    <span class="info-value"><?php echo e($invoice_number); ?></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Company:</span>
                    <span class="info-value"><?php echo e($company_name); ?></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Status:</span>
                    <span class="info-value" style="color: #10b981;">PAID</span>
                </div>
            </div>

            <?php if($attach_receipt && !empty($receipt_path)): ?>
            <div class="receipt-note">
                <strong>Receipt Attached:</strong><br>
                A digital receipt has been attached to this email for your records.
            </div>
            <?php endif; ?>

            <div class="thank-you">
                Thank you for your payment!
            </div>

            <div class="support-info">
                <p>This payment confirmation has been recorded in your account. You can view your payment history
                and download receipts from your NexaTrace dashboard.</p>

                <p>If you have any questions about this payment, please contact our support team at
                <a href="mailto:<?php echo e($support_email); ?>"><?php echo e($support_email); ?></a>.</p>

                <p>We appreciate your business!</p>
            </div>
        </div>

        <div class="footer">
            <p>&copy; <?php echo e(date('Y')); ?> NexaTrace. All rights reserved.</p>
            <p>This is an automated email, please do not reply to this message.</p>
        </div>
    </div>
</body>
</html>
<?php /**PATH C:\Ecosystem\NexaTrace_System\backend\resources\views\emails\payment_confirmation.blade.php ENDPATH**/ ?>