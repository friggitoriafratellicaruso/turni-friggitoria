# Turni · Friggitoria Fratelli Caruso

App per la gestione dei turni settimanali, integrata nello **stesso progetto Supabase di CrunchClub** (la carta fedeltà). Scambi soggetti ad approvazione admin, notifiche via WhatsApp.

## 1. Esegui lo script SQL
Vai su Supabase (`wxhysgthyebydoupsjrh.supabase.co`) → **SQL Editor** → incolla `schema.sql` → Run.

Questo crea solo 2 tabelle nuove (`turni_override`, `richieste_scambio`) che referenziano la tabella **`addetti` già esistente** — non tocca nulla di CrunchClub.

## 2. Verifica gli addetti
L'app turni usa gli STESSI addetti già registrati per la cassa/CrunchClub (sezione "Addetti" → PIN). Prima di usare l'app turni, controlla che Totò, Davide, Francesco, Mimmo e Vito siano già presenti lì, coi PIN che già conoscono.

Se non ci sono ancora, aggiungili dalla sezione Addetti dell'app CrunchClub esistente — non serve creare PIN nuovi da zero, sono già pronti per l'uso.

## 3. Configura il numero WhatsApp admin
Apri `index.html`, cerca "CONFIG" all'inizio dello script e imposta:
```js
const ADMIN_WHATSAPP = '393926893010'; // il tuo numero, senza +
```
URL e chiave Supabase sono già precompilati (stessi di CrunchClub).

## 4. Pubblica su GitHub Pages
1. Crea un nuovo repository, es. `turni-friggitoria`
2. Carica `index.html` **nella root** (nome obbligatorio per GitHub Pages)
3. Settings → Pages → Source: `main` branch, root
4. L'app sarà su `https://<tuo-utente>.github.io/turni-friggitoria/`

## Come funziona il riconoscimento degli addetti
L'app non ha nomi "cablati": legge tutti gli addetti attivi da Supabase e riconosce chi fa parte della rotazione turni cercando "toto", "davide", "francesco", "mimmo", "vito" nel campo `nome` (senza distinguere maiuscole/accenti). Se in futuro rinomini uno di questi addetti nella tabella `addetti`, aggiorna anche la funzione `groupKeyFor()` in `index.html`.

Altri eventuali addetti (es. un cassiere extra non coinvolto nei turni) restano visibili solo nel login ma non compaiono nel calendario turni.

## Come funziona il pattern automatico

**Gruppo rotazione (Totò, Davide, Francesco)**
- Turno standard: giornata intera 8:00–22:00
- A rotazione settimanale, uno di loro fa mezza giornata (8:00–16:00):
  - Ruolo A → lunedì + giovedì
  - Ruolo B → martedì + venerdì
  - Ruolo C → solo mercoledì
- Ogni settimana ciascuno avanza al ruolo successivo (A→B→C→A...)
- Ancorato alla settimana del 29/06/2026 = Totò:C, Davide:A, Francesco:B
- Sabato: sempre giornata intera per tutti e 3
- Possono scambiarsi solo la mezza giornata tra loro

**Gruppo fisso (Mimmo, Vito)**
- Mimmo: mattina fissa 8:00–16:00
- Vito: pomeriggio fisso 16:00–22:00
- Possono scambiarsi il turno tra loro

**Domenica:** chiuso.

## Modifiche manuali (ferie, malattie, ecc.)
Tab "Admin": forza un turno diverso dal pattern per una data specifica, senza toccare la rotazione automatica.

## Come funziona il flusso di scambio (3 fasi)

1. **Il dipendente A propone uno scambio** → si apre WhatsApp verso il collega B con un messaggio generico e il link all'app. Stato richiesta: "In attesa del collega".
2. **B apre l'app, accetta o rifiuta**:
   - Se rifiuta → richiesta chiusa, A riceve un WhatsApp con l'esito.
   - Se accetta → la richiesta NON è ancora valida: passa in stato "In attesa del titolare". A e B ricevono entrambi un WhatsApp che li avvisa dell'attesa, e tu (admin) ricevi un WhatsApp con il link per approvare.
3. **Tu approvi o rifiuti dall'app** → solo a questo punto lo scambio diventa effettivo nel calendario. A e B ricevono l'esito finale via WhatsApp.

L'ultima parola è sempre tua: l'accordo tra dipendenti al passo 2 è solo una proposta, non modifica il calendario finché non approvi.

## Numeri WhatsApp dei dipendenti
Sono impostati direttamente nel codice (`PHONE_NUMBERS` in `index.html`) invece che nel database, così restano fissi anche se aggiorni il file da GitHub. Per cambiarli, modifica quella costante.

## Nota sulle notifiche WhatsApp
Senza WhatsApp Business API, l'app apre link `wa.me` precompilati: basta premere invia, non è invio automatico in background. Ogni fase del flusso può aprire più schede WhatsApp in sequenza (una per destinatario) — il browser potrebbe chiedere il permesso di aprire popup multipli la prima volta.


