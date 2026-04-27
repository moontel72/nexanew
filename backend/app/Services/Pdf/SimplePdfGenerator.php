<?php

namespace App\Services\Pdf;

class SimplePdfGenerator
{
    public function generate(array $lines): string
    {
        $pageWidth = 612;
        $pageHeight = 792;
        $leftMargin = 50;
        $topMargin = 50;
        $fontSize = 10;
        $lineHeight = 12;
        $maxLinesPerPage = (int) floor(($pageHeight - ($topMargin * 2)) / $lineHeight);
        $maxLinesPerPage = max(10, $maxLinesPerPage);

        $pages = [];
        $current = [];
        foreach ($lines as $line) {
            $current[] = (string) $line;
            if (count($current) >= $maxLinesPerPage) {
                $pages[] = $current;
                $current = [];
            }
        }
        if (!empty($current)) {
            $pages[] = $current;
        }
        if (empty($pages)) {
            $pages = [[]];
        }

        $objects = [];

        $catalogId = 1;
        $pagesId = 2;
        $fontId = 3;

        $objects[$catalogId] = "<< /Type /Catalog /Pages {$pagesId} 0 R >>";

        $objects[$fontId] = "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>";

        $pageObjectIds = [];
        $nextId = 4;
        foreach ($pages as $pageLines) {
            $pageId = $nextId++;
            $contentsId = $nextId++;
            $pageObjectIds[] = $pageId;

            $content = $this->buildPageContent(
                $pageLines,
                $leftMargin,
                $pageHeight - $topMargin,
                $fontSize,
                $lineHeight,
            );

            $objects[$pageId] = "<< /Type /Page /Parent {$pagesId} 0 R /Resources << /Font << /F1 {$fontId} 0 R >> >> /MediaBox [0 0 {$pageWidth} {$pageHeight}] /Contents {$contentsId} 0 R >>";
            $objects[$contentsId] = $this->buildStreamObject($content);
        }

        $kids = implode(' ', array_map(fn ($id) => "{$id} 0 R", $pageObjectIds));
        $count = count($pageObjectIds);
        $objects[$pagesId] = "<< /Type /Pages /Kids [ {$kids} ] /Count {$count} >>";

        ksort($objects);

        $pdf = "%PDF-1.4\n";
        $offsets = [0];
        foreach ($objects as $id => $obj) {
            $offsets[$id] = strlen($pdf);
            $pdf .= "{$id} 0 obj\n{$obj}\nendobj\n";
        }

        $xrefStart = strlen($pdf);
        $maxId = max(array_keys($objects));
        $pdf .= "xref\n0 " . ($maxId + 1) . "\n";
        $pdf .= "0000000000 65535 f \n";
        for ($i = 1; $i <= $maxId; $i++) {
            $off = $offsets[$i] ?? 0;
            $pdf .= str_pad((string) $off, 10, '0', STR_PAD_LEFT) . " 00000 n \n";
        }

        $pdf .= "trailer\n<< /Size " . ($maxId + 1) . " /Root {$catalogId} 0 R >>\n";
        $pdf .= "startxref\n{$xrefStart}\n%%EOF";

        return $pdf;
    }

    private function buildPageContent(array $lines, int $x, int $y, int $fontSize, int $lineHeight): string
    {
        $out = "BT\n";
        $out .= "/F1 {$fontSize} Tf\n";
        $out .= "{$x} {$y} Td\n";

        foreach ($lines as $i => $line) {
            if ($i === 0) {
                $out .= "/F1 20 Tf\n";
            } elseif ($i === 1) {
                $out .= "/F1 14 Tf\n";
            } else {
                $out .= "/F1 {$fontSize} Tf\n";
            }

            $escaped = $this->escapePdfText((string) $line);
            $out .= "({$escaped}) Tj\n";
            if ($i !== count($lines) - 1) {
                if ($i === 0) {
                    $out .= "0 -24 Td\n";
                } elseif ($i === 1) {
                    $out .= "0 -18 Td\n";
                } else {
                    $out .= "0 -" . $lineHeight . " Td\n";
                }
            }
        }

        $out .= "ET\n";
        return $out;
    }

    private function buildStreamObject(string $content): string
    {
        $len = strlen($content);
        return "<< /Length {$len} >>\nstream\n{$content}\nendstream";
    }

    private function escapePdfText(string $text): string
    {
        $text = str_replace("\\", "\\\\", $text);
        $text = str_replace("(", "\\(", $text);
        $text = str_replace(")", "\\)", $text);
        $text = str_replace("\r", "", $text);
        $text = str_replace("\n", " ", $text);
        return $text;
    }
}
