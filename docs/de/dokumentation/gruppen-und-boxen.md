---
title: Gruppen und Boxen
lang: de
permalink: /dokumentation/nutzer/gruppen-und-boxen/
parent: Nutzerdokumentation
nav_order: 2
---

# Gruppen und Boxen

Vocabulaire verwaltet deine Vokabeln in Gruppen und Boxen.
Dabei ist eine Vokabel teil einer Box, welche ein Teil einer Gruppe ist.

Wir haben uns für diese Architektur entschieden, da sie dir einen hohen Abstraktionsgrad erlaubt.
Wie du mit dieser Architektur arbeitest kannst du frei entscheiden.

Es folgen Vorschläge, wie Gruppen und Boxen verwendet werden können:

## Vorschläge zur Vokabelverwaltung

* **Für Mehrsprachenlernende:** Erstelle eine Gruppe pro Sprache und erstelle verschiedene Kapitelboxen.
    * Beispiel (Lernziel: Deutsch und Englisch):
        * Gruppe: Deutsch
            * Box: Wetter
            * Box: Reisen
        * Gruppe: Englisch
            * Box: Weather
            * Box: Travel
            * Box: Countries
* **Für Einsprachenlernende:** Erstelle für jede gedankliche Trennung (z.B. Themengebiet, Lernbuchname oder Fortschritt)
  eine neue
  Gruppe.
    * Beispiel (Lernziel: Deutsch):
        * Gruppe: Reisen
            * Box: Ländernamen
            * Box: Nach dem Weg fragen
            * Box: Ticket kaufen

## Gruppentyp

Beim Anlegen einer Gruppe wählst du einen Typ, der danach nicht mehr geändert werden kann:

- **Vokabelgruppe (für Sprachen)**: für das Lernen einer Sprache, mit Ausgangs- und Zielsprache sowie den Zusatzfunktionen
  Konjugationen und Sprachausgabe.
- **Karteikartengruppe (einfachen Karteikarten)**: für beliebige Frage-Antwort-Karten mit allen Grundfunktionen, ohne Sprachbezug.

## Gruppe anlegen

Nach der Auswahl des Typs vergibst du einen Namen.
Bei einer Vokabelgruppe legst du zusätzlich Ausgangs- und Zielsprache fest.

## Online speichern

Standardmäßig werden Gruppen nur lokal auf deinem Gerät gespeichert. Mit [Premium]({{ '/dokumentation/nutzer/premium/' |
relative_url }}) kannst du eine Gruppe jederzeit über einen Schalter online speichern, um sie geräteübergreifend zu
synchronisieren.

## Löschen

Wenn du eine Gruppe löschst, werden auch alle darin enthaltenen Boxen gelöscht.
Diese Operation kann nicht widerrufen werden.
