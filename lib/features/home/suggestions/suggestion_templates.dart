class SuggestionWord {
  const SuggestionWord({
    required this.term,
    required this.ukIpa,
    required this.usIpa,
    required this.gloss,
    this.saveCount = 80,
  });

  final String term;
  final String ukIpa;
  final String usIpa;
  final String gloss;
  final int saveCount;
}

class SuggestionPack {
  const SuggestionPack({
    required this.id,
    required this.title,
    required this.words,
  });

  final String id;
  final String title;
  final List<SuggestionWord> words;

  SuggestionWord get lead => words.first;

  String get wordCountLabel => '${words.length} words';
}

abstract final class SuggestionTemplates {
  static const packs = <SuggestionPack>[
    SuggestionPack(
      id: 'healthcare',
      title: 'Healthcare',
      words: <SuggestionWord>[
        SuggestionWord(
          term: 'diagnosis',
          ukIpa: 'UK /ˌdaɪəɡˈnəʊsɪs/',
          usIpa: 'US /ˌdaɪəɡˈnoʊsɪs/',
          gloss: 'the identification of an illness or problem',
        ),
        SuggestionWord(
          term: 'prescription',
          ukIpa: 'UK /prɪˈskrɪpʃn/',
          usIpa: 'US /prɪˈskrɪpʃn/',
          gloss: 'a written order for medicine from a doctor',
        ),
        SuggestionWord(
          term: 'vitals',
          ukIpa: 'UK /ˈvaɪtlz/',
          usIpa: 'US /ˈvaɪtlz/',
          gloss: 'basic body signs such as pulse and temperature',
        ),
        SuggestionWord(
          term: 'triage',
          ukIpa: 'UK /ˈtriːɑːʒ/',
          usIpa: 'US /triˈɑːʒ/',
          gloss: 'sorting patients by urgency of need',
        ),
        SuggestionWord(
          term: 'outpatient',
          ukIpa: 'UK /ˈaʊtpeɪʃnt/',
          usIpa: 'US /ˈaʊtˌpeɪʃnt/',
          gloss: 'a patient treated without staying overnight',
        ),
        SuggestionWord(
          term: 'dosage',
          ukIpa: 'UK /ˈdəʊsɪdʒ/',
          usIpa: 'US /ˈdoʊsɪdʒ/',
          gloss: 'the amount of a medicine to take',
        ),
        SuggestionWord(
          term: 'vaccine',
          ukIpa: 'UK /ˈvæksiːn/',
          usIpa: 'US /vækˈsiːn/',
          gloss: 'a substance that protects against disease',
        ),
        SuggestionWord(
          term: 'surgery',
          ukIpa: 'UK /ˈsɜːdʒəri/',
          usIpa: 'US /ˈsɜːrdʒəri/',
          gloss: 'medical treatment that involves an operation',
        ),
        SuggestionWord(
          term: 'pathology',
          ukIpa: 'UK /pəˈθɒlədʒi/',
          usIpa: 'US /pəˈθɑːlədʒi/',
          gloss: 'the study of disease and its causes',
        ),
        SuggestionWord(
          term: 'radiology',
          ukIpa: 'UK /ˌreɪdiˈɒlədʒi/',
          usIpa: 'US /ˌreɪdiˈɑːlədʒi/',
          gloss: 'imaging used to examine the body',
        ),
        SuggestionWord(
          term: 'pharmacy',
          ukIpa: 'UK /ˈfɑːməsi/',
          usIpa: 'US /ˈfɑːrməsi/',
          gloss: 'a place that prepares and sells medicines',
        ),
        SuggestionWord(
          term: 'referral',
          ukIpa: 'UK /rɪˈfɜːrəl/',
          usIpa: 'US /rɪˈfɜːrəl/',
          gloss: 'sending a patient to another specialist',
        ),
      ],
    ),
    SuggestionPack(
      id: 'software',
      title: 'Software Engineering',
      words: <SuggestionWord>[
        SuggestionWord(
          term: 'deploy',
          ukIpa: 'UK /dɪˈplɔɪ/',
          usIpa: 'US /dɪˈplɔɪ/',
          gloss: 'to release software to a live environment',
        ),
        SuggestionWord(
          term: 'refactor',
          ukIpa: 'UK /riːˈfæktə/',
          usIpa: 'US /riːˈfæktər/',
          gloss: 'to restructure code without changing behavior',
        ),
        SuggestionWord(
          term: 'pull request',
          ukIpa: 'UK /ˈpʊl rɪˌkwest/',
          usIpa: 'US /ˈpʊl rɪˌkwest/',
          gloss: 'a proposal to merge code changes',
        ),
        SuggestionWord(
          term: 'latency',
          ukIpa: 'UK /ˈleɪtənsi/',
          usIpa: 'US /ˈleɪtənsi/',
          gloss: 'the delay before a transfer of data begins',
        ),
        SuggestionWord(
          term: 'backlog',
          ukIpa: 'UK /ˈbæklɒɡ/',
          usIpa: 'US /ˈbæklɔːɡ/',
          gloss: 'a prioritized list of work to do',
        ),
        SuggestionWord(
          term: 'endpoint',
          ukIpa: 'UK /ˈendpɔɪnt/',
          usIpa: 'US /ˈendˌpɔɪnt/',
          gloss: 'a URL where an API can be accessed',
        ),
        SuggestionWord(
          term: 'commit',
          ukIpa: 'UK /kəˈmɪt/',
          usIpa: 'US /kəˈmɪt/',
          gloss: 'a saved snapshot of code changes',
        ),
        SuggestionWord(
          term: 'branch',
          ukIpa: 'UK /brɑːntʃ/',
          usIpa: 'US /bræntʃ/',
          gloss: 'a line of development in version control',
        ),
        SuggestionWord(
          term: 'pipeline',
          ukIpa: 'UK /ˈpaɪplaɪn/',
          usIpa: 'US /ˈpaɪpˌlaɪn/',
          gloss: 'an automated sequence of build steps',
        ),
        SuggestionWord(
          term: 'rollback',
          ukIpa: 'UK /ˈrəʊlbæk/',
          usIpa: 'US /ˈroʊlbæk/',
          gloss: 'reverting to a previous working version',
        ),
        SuggestionWord(
          term: 'container',
          ukIpa: 'UK /kənˈteɪnə/',
          usIpa: 'US /kənˈteɪnər/',
          gloss: 'a packaged runtime for an application',
        ),
        SuggestionWord(
          term: 'runtime',
          ukIpa: 'UK /ˈrʌntaɪm/',
          usIpa: 'US /ˈrʌnˌtaɪm/',
          gloss: 'the period when a program is executing',
        ),
      ],
    ),
    SuggestionPack(
      id: 'finance',
      title: 'Finance & Banking',
      words: <SuggestionWord>[
        SuggestionWord(
          term: 'invoice',
          ukIpa: 'UK /ˈɪnvɔɪs/',
          usIpa: 'US /ˈɪnvɔɪs/',
          gloss: 'a bill requesting payment for goods or services',
        ),
        SuggestionWord(
          term: 'interest rate',
          ukIpa: 'UK /ˈɪntrəst reɪt/',
          usIpa: 'US /ˈɪntrəst reɪt/',
          gloss: 'the cost of borrowing money over time',
        ),
        SuggestionWord(
          term: 'portfolio',
          ukIpa: 'UK /pɔːtˈfəʊliəʊ/',
          usIpa: 'US /pɔːrtˈfoʊlioʊ/',
          gloss: 'a collection of investments held together',
        ),
        SuggestionWord(
          term: 'liquidity',
          ukIpa: 'UK /lɪˈkwɪdəti/',
          usIpa: 'US /lɪˈkwɪdəti/',
          gloss: 'how easily an asset can be turned into cash',
        ),
        SuggestionWord(
          term: 'equity',
          ukIpa: 'UK /ˈekwəti/',
          usIpa: 'US /ˈekwəti/',
          gloss: 'ownership value in a company or asset',
        ),
        SuggestionWord(
          term: 'audit',
          ukIpa: 'UK /ˈɔːdɪt/',
          usIpa: 'US /ˈɔːdɪt/',
          gloss: 'an official examination of accounts',
        ),
        SuggestionWord(
          term: 'ledger',
          ukIpa: 'UK /ˈledʒə/',
          usIpa: 'US /ˈledʒər/',
          gloss: 'a book or system of financial records',
        ),
        SuggestionWord(
          term: 'collateral',
          ukIpa: 'UK /kəˈlætərəl/',
          usIpa: 'US /kəˈlætərəl/',
          gloss: 'an asset pledged to secure a loan',
        ),
        SuggestionWord(
          term: 'dividend',
          ukIpa: 'UK /ˈdɪvɪdend/',
          usIpa: 'US /ˈdɪvɪdend/',
          gloss: 'a share of profits paid to shareholders',
        ),
        SuggestionWord(
          term: 'bond',
          ukIpa: 'UK /bɒnd/',
          usIpa: 'US /bɑːnd/',
          gloss: 'a loan made by an investor to a borrower',
        ),
        SuggestionWord(
          term: 'forex',
          ukIpa: 'UK /ˈfɒreks/',
          usIpa: 'US /ˈfɔːreks/',
          gloss: 'the market for trading currencies',
        ),
        SuggestionWord(
          term: 'balance sheet',
          ukIpa: 'UK /ˈbæləns ʃiːt/',
          usIpa: 'US /ˈbæləns ʃiːt/',
          gloss: 'a statement of assets and liabilities',
        ),
      ],
    ),
    SuggestionPack(
      id: 'hospitality',
      title: 'Hospitality & Tourism',
      words: <SuggestionWord>[
        SuggestionWord(
          term: 'check-in',
          ukIpa: 'UK /ˈtʃekɪn/',
          usIpa: 'US /ˈtʃekˌɪn/',
          gloss: 'the process of registering on arrival',
        ),
        SuggestionWord(
          term: 'itinerary',
          ukIpa: 'UK /aɪˈtɪnərəri/',
          usIpa: 'US /aɪˈtɪnəreri/',
          gloss: 'a planned route or schedule of travel',
        ),
        SuggestionWord(
          term: 'amenity',
          ukIpa: 'UK /əˈmiːnəti/',
          usIpa: 'US /əˈmenəti/',
          gloss: 'a useful or pleasant facility for guests',
        ),
        SuggestionWord(
          term: 'concierge',
          ukIpa: 'UK /ˈkɒnsieəʒ/',
          usIpa: 'US /ˌkɑːnsiˈerʒ/',
          gloss: 'staff who help guests with services',
        ),
        SuggestionWord(
          term: 'reservation',
          ukIpa: 'UK /ˌrezəˈveɪʃn/',
          usIpa: 'US /ˌrezərˈveɪʃn/',
          gloss: 'a booking held for a guest or traveler',
        ),
        SuggestionWord(
          term: 'occupancy',
          ukIpa: 'UK /ˈɒkjəpənsi/',
          usIpa: 'US /ˈɑːkjəpənsi/',
          gloss: 'the share of rooms that are filled',
        ),
        SuggestionWord(
          term: 'housekeeping',
          ukIpa: 'UK /ˈhaʊskiːpɪŋ/',
          usIpa: 'US /ˈhaʊsˌkiːpɪŋ/',
          gloss: 'cleaning and preparing guest rooms',
        ),
        SuggestionWord(
          term: 'suite',
          ukIpa: 'UK /swiːt/',
          usIpa: 'US /swiːt/',
          gloss: 'a set of connected hotel rooms',
        ),
        SuggestionWord(
          term: 'layover',
          ukIpa: 'UK /ˈleɪəʊvə/',
          usIpa: 'US /ˈleɪˌoʊvər/',
          gloss: 'a stop between flights on a journey',
        ),
        SuggestionWord(
          term: 'visa',
          ukIpa: 'UK /ˈviːzə/',
          usIpa: 'US /ˈviːzə/',
          gloss: 'official permission to enter a country',
        ),
        SuggestionWord(
          term: 'baggage',
          ukIpa: 'UK /ˈbæɡɪdʒ/',
          usIpa: 'US /ˈbæɡɪdʒ/',
          gloss: 'luggage taken on a trip',
        ),
        SuggestionWord(
          term: 'lobby',
          ukIpa: 'UK /ˈlɒbi/',
          usIpa: 'US /ˈlɑːbi/',
          gloss: 'the entrance hall of a hotel',
        ),
      ],
    ),
    SuggestionPack(
      id: 'marketing',
      title: 'Marketing & Sales',
      words: <SuggestionWord>[
        SuggestionWord(
          term: 'conversion',
          ukIpa: 'UK /kənˈvɜːʃn/',
          usIpa: 'US /kənˈvɜːrʒn/',
          gloss: 'turning a visitor into a customer',
        ),
        SuggestionWord(
          term: 'lead',
          ukIpa: 'UK /liːd/',
          usIpa: 'US /liːd/',
          gloss: 'a potential customer contact',
        ),
        SuggestionWord(
          term: 'funnel',
          ukIpa: 'UK /ˈfʌnl/',
          usIpa: 'US /ˈfʌnl/',
          gloss: 'stages from awareness to purchase',
        ),
        SuggestionWord(
          term: 'campaign',
          ukIpa: 'UK /kæmˈpeɪn/',
          usIpa: 'US /kæmˈpeɪn/',
          gloss: 'a planned set of marketing actions',
        ),
        SuggestionWord(
          term: 'CTA',
          ukIpa: 'UK /ˌsiː tiː ˈeɪ/',
          usIpa: 'US /ˌsiː tiː ˈeɪ/',
          gloss: 'a call to action that prompts a response',
        ),
        SuggestionWord(
          term: 'retention',
          ukIpa: 'UK /rɪˈtenʃn/',
          usIpa: 'US /rɪˈtenʃn/',
          gloss: 'keeping customers over time',
        ),
        SuggestionWord(
          term: 'branding',
          ukIpa: 'UK /ˈbrændɪŋ/',
          usIpa: 'US /ˈbrændɪŋ/',
          gloss: 'how a product is presented and known',
        ),
        SuggestionWord(
          term: 'segment',
          ukIpa: 'UK /ˈseɡmənt/',
          usIpa: 'US /ˈseɡmənt/',
          gloss: 'a group of customers with shared traits',
        ),
        SuggestionWord(
          term: 'outreach',
          ukIpa: 'UK /ˈaʊtriːtʃ/',
          usIpa: 'US /ˈaʊtˌriːtʃ/',
          gloss: 'contacting prospects to start a sale',
        ),
        SuggestionWord(
          term: 'upsell',
          ukIpa: 'UK /ˈʌpsel/',
          usIpa: 'US /ˈʌpˌsel/',
          gloss: 'encouraging a higher-value purchase',
        ),
        SuggestionWord(
          term: 'quota',
          ukIpa: 'UK /ˈkwəʊtə/',
          usIpa: 'US /ˈkwoʊtə/',
          gloss: 'a sales target to be reached',
        ),
        SuggestionWord(
          term: 'pipeline',
          ukIpa: 'UK /ˈpaɪplaɪn/',
          usIpa: 'US /ˈpaɪpˌlaɪn/',
          gloss: 'deals in progress toward closing',
        ),
      ],
    ),
    SuggestionPack(
      id: 'education',
      title: 'Education & Teaching',
      words: <SuggestionWord>[
        SuggestionWord(
          term: 'curriculum',
          ukIpa: 'UK /kəˈrɪkjələm/',
          usIpa: 'US /kəˈrɪkjələm/',
          gloss: 'the subjects taught in a course of study',
        ),
        SuggestionWord(
          term: 'assessment',
          ukIpa: 'UK /əˈsesmənt/',
          usIpa: 'US /əˈsesmənt/',
          gloss: 'a judgment of a learner’s knowledge',
        ),
        SuggestionWord(
          term: 'rubric',
          ukIpa: 'UK /ˈruːbrɪk/',
          usIpa: 'US /ˈruːbrɪk/',
          gloss: 'a guide for scoring student work',
        ),
        SuggestionWord(
          term: 'enrollment',
          ukIpa: 'UK /ɪnˈrəʊlmənt/',
          usIpa: 'US /ɪnˈroʊlmənt/',
          gloss: 'the act of registering for a course',
        ),
        SuggestionWord(
          term: 'syllabus',
          ukIpa: 'UK /ˈsɪləbəs/',
          usIpa: 'US /ˈsɪləbəs/',
          gloss: 'an outline of topics for a class',
        ),
        SuggestionWord(
          term: 'literacy',
          ukIpa: 'UK /ˈlɪtərəsi/',
          usIpa: 'US /ˈlɪtərəsi/',
          gloss: 'the ability to read and write',
        ),
        SuggestionWord(
          term: 'lecture',
          ukIpa: 'UK /ˈlektʃə/',
          usIpa: 'US /ˈlektʃər/',
          gloss: 'a talk given to teach a subject',
        ),
        SuggestionWord(
          term: 'tutor',
          ukIpa: 'UK /ˈtjuːtə/',
          usIpa: 'US /ˈtuːtər/',
          gloss: 'a teacher who works with few students',
        ),
        SuggestionWord(
          term: 'homework',
          ukIpa: 'UK /ˈhəʊmwɜːk/',
          usIpa: 'US /ˈhoʊmwɜːrk/',
          gloss: 'tasks assigned to do outside class',
        ),
        SuggestionWord(
          term: 'diploma',
          ukIpa: 'UK /dɪˈpləʊmə/',
          usIpa: 'US /dɪˈploʊmə/',
          gloss: 'a document showing a completed course',
        ),
        SuggestionWord(
          term: 'faculty',
          ukIpa: 'UK /ˈfæklti/',
          usIpa: 'US /ˈfækəlti/',
          gloss: 'the teaching staff of a school',
        ),
        SuggestionWord(
          term: 'seminar',
          ukIpa: 'UK /ˈsemɪnɑː/',
          usIpa: 'US /ˈsemɪnɑːr/',
          gloss: 'a small class for discussion and study',
        ),
      ],
    ),
    SuggestionPack(
      id: 'law',
      title: 'Law & Legal',
      words: <SuggestionWord>[
        SuggestionWord(
          term: 'liability',
          ukIpa: 'UK /ˌlaɪəˈbɪləti/',
          usIpa: 'US /ˌlaɪəˈbɪləti/',
          gloss: 'legal responsibility for something',
        ),
        SuggestionWord(
          term: 'contract',
          ukIpa: 'UK /ˈkɒntrækt/',
          usIpa: 'US /ˈkɑːntrækt/',
          gloss: 'a binding agreement between parties',
        ),
        SuggestionWord(
          term: 'plaintiff',
          ukIpa: 'UK /ˈpleɪntɪf/',
          usIpa: 'US /ˈpleɪntɪf/',
          gloss: 'the person who brings a lawsuit',
        ),
        SuggestionWord(
          term: 'statute',
          ukIpa: 'UK /ˈstætʃuːt/',
          usIpa: 'US /ˈstætʃuːt/',
          gloss: 'a written law passed by a legislature',
        ),
        SuggestionWord(
          term: 'clause',
          ukIpa: 'UK /klɔːz/',
          usIpa: 'US /klɔːz/',
          gloss: 'a distinct section of a legal document',
        ),
        SuggestionWord(
          term: 'deposition',
          ukIpa: 'UK /ˌdepəˈzɪʃn/',
          usIpa: 'US /ˌdepəˈzɪʃn/',
          gloss: 'sworn out-of-court testimony',
        ),
        SuggestionWord(
          term: 'affidavit',
          ukIpa: 'UK /ˌæfɪˈdeɪvɪt/',
          usIpa: 'US /ˌæfɪˈdeɪvɪt/',
          gloss: 'a written statement sworn to be true',
        ),
        SuggestionWord(
          term: 'counsel',
          ukIpa: 'UK /ˈkaʊnsl/',
          usIpa: 'US /ˈkaʊnsl/',
          gloss: 'a lawyer representing a client',
        ),
        SuggestionWord(
          term: 'verdict',
          ukIpa: 'UK /ˈvɜːdɪkt/',
          usIpa: 'US /ˈvɜːrdɪkt/',
          gloss: 'the decision reached by a jury or judge',
        ),
        SuggestionWord(
          term: 'injunction',
          ukIpa: 'UK /ɪnˈdʒʌŋkʃn/',
          usIpa: 'US /ɪnˈdʒʌŋkʃn/',
          gloss: 'a court order to do or stop doing something',
        ),
        SuggestionWord(
          term: 'tort',
          ukIpa: 'UK /tɔːt/',
          usIpa: 'US /tɔːrt/',
          gloss: 'a civil wrong causing harm or loss',
        ),
        SuggestionWord(
          term: 'jurisdiction',
          ukIpa: 'UK /ˌdʒʊərɪsˈdɪkʃn/',
          usIpa: 'US /ˌdʒʊrɪsˈdɪkʃn/',
          gloss: 'the authority to hear and decide cases',
        ),
      ],
    ),
    SuggestionPack(
      id: 'logistics',
      title: 'Logistics & Supply Chain',
      words: <SuggestionWord>[
        SuggestionWord(
          term: 'shipment',
          ukIpa: 'UK /ˈʃɪpmənt/',
          usIpa: 'US /ˈʃɪpmənt/',
          gloss: 'goods sent from one place to another',
        ),
        SuggestionWord(
          term: 'warehouse',
          ukIpa: 'UK /ˈweəhaʊs/',
          usIpa: 'US /ˈwerhaʊs/',
          gloss: 'a building for storing goods',
        ),
        SuggestionWord(
          term: 'lead time',
          ukIpa: 'UK /ˈliːd taɪm/',
          usIpa: 'US /ˈliːd taɪm/',
          gloss: 'the delay from order to delivery',
        ),
        SuggestionWord(
          term: 'inventory',
          ukIpa: 'UK /ˈɪnvəntri/',
          usIpa: 'US /ˈɪnvəntɔːri/',
          gloss: 'stock of goods held for sale or use',
        ),
        SuggestionWord(
          term: 'freight',
          ukIpa: 'UK /freɪt/',
          usIpa: 'US /freɪt/',
          gloss: 'goods transported in bulk',
        ),
        SuggestionWord(
          term: 'SKU',
          ukIpa: 'UK /ˌes keɪ ˈjuː/',
          usIpa: 'US /ˌes keɪ ˈjuː/',
          gloss: 'a stock keeping unit for a product',
        ),
        SuggestionWord(
          term: 'pallet',
          ukIpa: 'UK /ˈpælɪt/',
          usIpa: 'US /ˈpælɪt/',
          gloss: 'a flat base for stacking and moving goods',
        ),
        SuggestionWord(
          term: 'customs',
          ukIpa: 'UK /ˈkʌstəmz/',
          usIpa: 'US /ˈkʌstəmz/',
          gloss: 'checks on goods entering a country',
        ),
        SuggestionWord(
          term: 'carrier',
          ukIpa: 'UK /ˈkæriə/',
          usIpa: 'US /ˈkæriər/',
          gloss: 'a company that transports goods',
        ),
        SuggestionWord(
          term: 'fulfillment',
          ukIpa: 'UK /fʊlˈfɪlmənt/',
          usIpa: 'US /fʊlˈfɪlmənt/',
          gloss: 'picking, packing, and shipping an order',
        ),
        SuggestionWord(
          term: 'transit',
          ukIpa: 'UK /ˈtrænzɪt/',
          usIpa: 'US /ˈtrænzɪt/',
          gloss: 'the process of being moved somewhere',
        ),
        SuggestionWord(
          term: 'logistics',
          ukIpa: 'UK /ləˈdʒɪstɪks/',
          usIpa: 'US /ləˈdʒɪstɪks/',
          gloss: 'planning the movement of goods',
        ),
      ],
    ),
    SuggestionPack(
      id: 'design',
      title: 'Design & Creative',
      words: <SuggestionWord>[
        SuggestionWord(
          term: 'wireframe',
          ukIpa: 'UK /ˈwaɪəfreɪm/',
          usIpa: 'US /ˈwaɪərfreɪm/',
          gloss: 'a basic outline of a page layout',
        ),
        SuggestionWord(
          term: 'mockup',
          ukIpa: 'UK /ˈmɒkʌp/',
          usIpa: 'US /ˈmɑːkʌp/',
          gloss: 'a realistic model of a design',
        ),
        SuggestionWord(
          term: 'typography',
          ukIpa: 'UK /taɪˈpɒɡrəfi/',
          usIpa: 'US /taɪˈpɑːɡrəfi/',
          gloss: 'the style and arrangement of text',
        ),
        SuggestionWord(
          term: 'portfolio',
          ukIpa: 'UK /pɔːtˈfəʊliəʊ/',
          usIpa: 'US /pɔːrtˈfoʊlioʊ/',
          gloss: 'a collection of creative work samples',
        ),
        SuggestionWord(
          term: 'brief',
          ukIpa: 'UK /briːf/',
          usIpa: 'US /briːf/',
          gloss: 'instructions describing a design task',
        ),
        SuggestionWord(
          term: 'prototype',
          ukIpa: 'UK /ˈprəʊtətaɪp/',
          usIpa: 'US /ˈproʊtətaɪp/',
          gloss: 'an early working model of a product',
        ),
        SuggestionWord(
          term: 'layout',
          ukIpa: 'UK /ˈleɪaʊt/',
          usIpa: 'US /ˈleɪˌaʊt/',
          gloss: 'how elements are arranged on a page',
        ),
        SuggestionWord(
          term: 'palette',
          ukIpa: 'UK /ˈpælət/',
          usIpa: 'US /ˈpælət/',
          gloss: 'a set of colors used in a design',
        ),
        SuggestionWord(
          term: 'storyboard',
          ukIpa: 'UK /ˈstɔːribɔːd/',
          usIpa: 'US /ˈstɔːriˌbɔːrd/',
          gloss: 'a sequence of frames planning a story',
        ),
        SuggestionWord(
          term: 'illustration',
          ukIpa: 'UK /ˌɪləˈstreɪʃn/',
          usIpa: 'US /ˌɪləˈstreɪʃn/',
          gloss: 'a drawn or digital visual image',
        ),
        SuggestionWord(
          term: 'grid',
          ukIpa: 'UK /ɡrɪd/',
          usIpa: 'US /ɡrɪd/',
          gloss: 'a structure of lines for aligning content',
        ),
        SuggestionWord(
          term: 'brand kit',
          ukIpa: 'UK /ˈbrænd kɪt/',
          usIpa: 'US /ˈbrænd kɪt/',
          gloss: 'assets that define a brand’s look',
        ),
      ],
    ),
    SuggestionPack(
      id: 'support',
      title: 'Customer Support',
      words: <SuggestionWord>[
        SuggestionWord(
          term: 'ticket',
          ukIpa: 'UK /ˈtɪkɪt/',
          usIpa: 'US /ˈtɪkɪt/',
          gloss: 'a tracked customer support request',
        ),
        SuggestionWord(
          term: 'escalate',
          ukIpa: 'UK /ˈeskəleɪt/',
          usIpa: 'US /ˈeskəleɪt/',
          gloss: 'to pass an issue to a higher level',
        ),
        SuggestionWord(
          term: 'SLA',
          ukIpa: 'UK /ˌes el ˈeɪ/',
          usIpa: 'US /ˌes el ˈeɪ/',
          gloss: 'a service level agreement on response time',
        ),
        SuggestionWord(
          term: 'refund',
          ukIpa: 'UK /ˈriːfʌnd/',
          usIpa: 'US /ˈriːfʌnd/',
          gloss: 'money returned to a customer',
        ),
        SuggestionWord(
          term: 'troubleshooting',
          ukIpa: 'UK /ˈtrʌblʃuːtɪŋ/',
          usIpa: 'US /ˈtrʌblˌʃuːtɪŋ/',
          gloss: 'finding and fixing a problem',
        ),
        SuggestionWord(
          term: 'follow-up',
          ukIpa: 'UK /ˈfɒləʊʌp/',
          usIpa: 'US /ˈfɑːloʊˌʌp/',
          gloss: 'a later contact to check on progress',
        ),
        SuggestionWord(
          term: 'chatbot',
          ukIpa: 'UK /ˈtʃætbɒt/',
          usIpa: 'US /ˈtʃætbɑːt/',
          gloss: 'software that answers customer messages',
        ),
        SuggestionWord(
          term: 'knowledge base',
          ukIpa: 'UK /ˈnɒlɪdʒ beɪs/',
          usIpa: 'US /ˈnɑːlɪdʒ beɪs/',
          gloss: 'a library of help articles',
        ),
        SuggestionWord(
          term: 'resolution',
          ukIpa: 'UK /ˌrezəˈluːʃn/',
          usIpa: 'US /ˌrezəˈluːʃn/',
          gloss: 'the final fix for a support issue',
        ),
        SuggestionWord(
          term: 'outage',
          ukIpa: 'UK /ˈaʊtɪdʒ/',
          usIpa: 'US /ˈaʊtɪdʒ/',
          gloss: 'a period when a service is unavailable',
        ),
        SuggestionWord(
          term: 'agent',
          ukIpa: 'UK /ˈeɪdʒənt/',
          usIpa: 'US /ˈeɪdʒənt/',
          gloss: 'a person who handles support tickets',
        ),
        SuggestionWord(
          term: 'priority',
          ukIpa: 'UK /praɪˈɒrəti/',
          usIpa: 'US /praɪˈɔːrəti/',
          gloss: 'how urgently an issue should be handled',
        ),
      ],
    ),
  ];

  static List<String> get chips => <String>[
    for (final pack in packs) pack.lead.term,
  ];

  static List<String> get sets => <String>[
    for (final pack in packs) pack.title,
  ];

  static List<String> get practice => <String>[
    for (final pack in packs) 'Practice "${pack.lead.term}"',
  ];

  static SuggestionPack get defaultPack => packs.first;

  static SuggestionWord get wordCard => defaultPack.lead;

  static String get word => wordCard.term;
  static String get uk => wordCard.ukIpa;
  static String get us => wordCard.usIpa;
  static String get gloss => wordCard.gloss;
  static int get saveCount => wordCard.saveCount;

  static SuggestionPack? packForTerm(String term) {
    for (final pack in packs) {
      for (final entry in pack.words) {
        if (entry.term == term) {
          return pack;
        }
      }
    }
    return null;
  }

  static SuggestionWord? wordInPack(SuggestionPack pack, String term) {
    for (final entry in pack.words) {
      if (entry.term == term) {
        return entry;
      }
    }
    return null;
  }
}
