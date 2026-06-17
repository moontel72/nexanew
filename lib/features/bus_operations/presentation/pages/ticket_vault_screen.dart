// NEXATRACE — TICKET VAULT SCREEN
// ==================================
// Offline ticket wallet showing all cached bus tickets.
// Passengers access this even without internet to display
// boarding passes with QR codes.
//
// ROUTE:  /bus-fleet/my-tickets
//
// MODULE: 8V — Digital QR Ticketing Vault

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:trace_odd/features/bus_operations/data/services/ticket_vault_service.dart';
import 'package:trace_odd/features/bus_operations/presentation/widgets/qr_code_painter.dart';

class TicketVaultScreen extends StatefulWidget {
  const TicketVaultScreen({super.key});
  @override
  State<TicketVaultScreen> createState() => _TicketVaultScreenState();
}

class _TicketVaultScreenState extends State<TicketVaultScreen> {
  final TicketVaultService _vault = TicketVaultService();
  List<CachedBusTicket> _tickets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _vault.init();
    setState(() {
      _tickets = _vault.getAllTickets();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Tickets',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
          : _tickets.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tickets.length,
              itemBuilder: (_, i) => _buildTicketCard(_tickets[i], theme),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const Gap(16),
          const Text(
            'No tickets yet',
            style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8)),
          ),
          const Gap(8),
          const Text(
            'Booked tickets will appear here for offline access',
            style: TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(CachedBusTicket ticket, ThemeData theme) {
    final isActive = ticket.isValid;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: ticket)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      (isActive
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF94A3B8))
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive ? Icons.qr_code : Icons.check_circle_outline,
                  color: isActive
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF94A3B8),
                  size: 24,
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.busDisplayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Seat ${ticket.seatLabel} · Rs. ${ticket.ticketPrice.toInt()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const Gap(2),
                    Text(
                      ticket.bookedAtDisplay,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? 'Active' : ticket.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketDetailScreen extends StatelessWidget {
  final CachedBusTicket ticket;
  const TicketDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Boarding Pass')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: CustomPaint(
                      painter: QrCodePainter(payload: ticket.displayQr),
                      size: Size.infinite,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    ticket.displayQr,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _row('Bus', ticket.busDisplayName, theme),
                  _row('Seat', ticket.seatLabel, theme),
                  _row('Price', 'Rs. ${ticket.ticketPrice.toInt()}', theme),
                  _row('Payment', ticket.paymentMethod, theme),
                  _row('Booked', ticket.bookedAtDisplay, theme),
                  _row('Booking ID', ticket.bookingId, theme, mono: true),
                  _row(
                    'Status',
                    ticket.status.toUpperCase(),
                    theme,
                    valueColor: ticket.isValid
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
            const Gap(24),
            if (ticket.isValid)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Show this QR to the conductor for boarding',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  label: const Text('Ready to Board'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String value,
    ThemeData theme, {
    Color? valueColor,
    bool mono = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: mono ? 'monospace' : null,
              color: valueColor ?? const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
