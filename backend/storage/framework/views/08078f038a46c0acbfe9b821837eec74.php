<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invoice <?php echo e($invoice_number); ?> - NexaTrace</title>
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
        .invoice-info {
            background-color: #f8f9fa;
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
        .amount-highlight {
            font-size: 28px;
            font-weight: 700;
            color: #10b981;
            text-align: center;
            margin: 20px 0;
        }
        .items-table {
            width: 100%;
            border-collapse: collapse;
            margin: 25px 0;
        }
        .items-table th {
            background-color: #f8f9fa;
            padding: 12px 15px;
            text-align: left;
            font-weight: 600;
            color: #555;
            border-bottom: 2px solid #e9ecef;
        }
        .items-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #e9ecef;
        }
        .items-table tr:last-child td {
            border-bottom: none;
        }
        .total-row {
            background-color: #f8f9fa;
            font-weight: 600;
        }
        .action-button {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            padding: 12px 30px;
            border-radius: 6px;
            font-weight: 600;
            margin: 20px 0;
            text-align: center;
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
        .notes {
            background-color: #fff3cd;
            border-left: 4px solid #ffc107;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .payment-instructions {
            background-color: #d1ecf1;
            border-left: 4px solid #0dcaf0;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }
        @media (max-width: 600px) {
            .content {
                padding: 20px;
            }
            .info-row {
                flex-direction: column;
            }
            .info-value {
                margin-top: 5px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">NexaTrace</div>
            <h1 class="title">Invoice <?php echo e($invoice_number); ?></h1>
        </div>

        <div class="content">
            <p>Dear <?php echo e($to_name); ?>,</p>

            <p>Please find attached your invoice from NexaTrace. Below are the details:</p>

            <div class="invoice-info">
                <div class="info-row">
                    <span class="info-label">Company:</span>
                    <span class="info-value"><?php echo e($company_name); ?></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Invoice Number:</span>
                    <span class="info-value"><?php echo e($invoice_number); ?></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Issue Date:</span>
                    <span class="info-value"><?php echo e($issue_date); ?></span>
                </div>
                <div class="info-row">
                    <span class="info-label">Due Date:</span>
                    <span class="info-value"><?php echo e($due_date); ?></span>
                </div>
            </div>

            <div class="amount-highlight">
                <?php echo e($currency); ?> <?php echo e($total_amount); ?>

            </div>

            <?php if(!empty($items) && count($items) > 0): ?>
            <table class="items-table">
                <thead>
                    <tr>
                        <th>Description</th>
                        <th>Quantity</th>
                        <th>Unit Price</th>
                        <th>Total</th>
                    </tr>
                </thead>
                <tbody>
                    <?php $__currentLoopData = $items; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $item): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                    <tr>
                        <td><?php echo e($item['description']); ?></td>
                        <td><?php echo e(number_format($item['quantity'], 2)); ?></td>
                        <td><?php echo e($currency); ?> <?php echo e(number_format($item['unit_price'], 2)); ?></td>
                        <td><?php echo e($currency); ?> <?php echo e(number_format($item['total'], 2)); ?></td>
                    </tr>
                    <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
                    <tr class="total-row">
                        <td colspan="3" style="text-align: right;"><strong>Total Amount:</strong></td>
                        <td><strong><?php echo e($currency); ?> <?php echo e($total_amount); ?></strong></td>
                    </tr>
                </tbody>
            </table>
            <?php endif; ?>

            <?php if(!empty($notes)): ?>
            <div class="notes">
                <strong>Notes:</strong><br>
                <?php echo e($notes); ?>

            </div>
            <?php endif; ?>

            <?php if(!empty($payment_instructions)): ?>
            <div class="payment-instructions">
                <strong>Payment Instructions:</strong><br>
                <?php echo nl2br(e($payment_instructions)); ?>

            </div>
            <?php endif; ?>

            <?php if(!empty($payment_url)): ?>
            <div style="text-align: center;">
                <a href="<?php echo e($payment_url); ?>" class="action-button">Pay Invoice Online</a>
            </div>
            <?php endif; ?>

            <?php if(!empty($invoice_url)): ?>
            <p style="text-align: center;">
                <a href="<?php echo e($invoice_url); ?>">View Invoice Online</a>
            </p>
            <?php endif; ?>

            <div class="support-info">
                <p>If you have any questions about this invoice, please contact our support team at
                <a href="mailto:<?php echo e($support_email); ?>"><?php echo e($support_email); ?></a>.</p>

                <p>Thank you for choosing NexaTrace!</p>
            </div>
        </div>

        <div class="footer">
            <p>&copy; <?php echo e(date('Y')); ?> NexaTrace. All rights reserved.</p>
            <p>This is an automated email, please do not reply to this message.</p>
        </div>
    </div>
</body>
</html>
<?php /**PATH C:\Ecosystem\NexaTrace_System\backend\resources\views\emails\invoice.blade.php ENDPATH**/ ?>