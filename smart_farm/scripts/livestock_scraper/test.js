const axios = require('axios');
const cheerio = require('cheerio');

async function scrapeLivestock() {
  try {
    const { data } = await axios.get('https://chicken-rate.com');
    const $ = cheerio.load(data);
    
    // Find all rows in all tables
    let allRows = [];
    $('table tr').each((i, row) => {
        let cols = [];
        $(row).find('td, th').each((j, col) => {
            cols.push($(col).text().trim());
        });
        if(cols.length > 0) allRows.push(cols);
    });

    console.log(`Found ${allRows.length} rows across tables.`);
    console.log('Sample rows:');
    allRows.slice(0, 15).forEach(r => console.log(r.join(' | ')));

  } catch(e) {
    console.error("error:", e);
  }
}
scrapeLivestock();
