// Truncate text to specified number of characters
function truncateText(text, maxLength) {
    if (!text) return '';
    if (text.length > maxLength) {
        return text.substring(0, maxLength).trim() + '...';
    }
    return text;
}

function parseArticleDate(dateString) {
    if (!dateString) return NaN;
    const normalized = dateString.trim().replace(/\s*-\s*/g, '-').replace(/\//g, '-');
    const parsed = new Date(normalized);
    return isNaN(parsed.getTime()) ? NaN : parsed.getTime();
}

// Load Latest News section dynamically from articles.json
async function loadLatestNews() {
    try {
        const response = await fetch('articles.json');
        const articles = await response.json();

        // Urutkan artikel berdasarkan tanggal terbaru terlebih dahulu,
        // lalu ambil 12 teratas untuk ditampilkan di halaman Home.
        const latestArticles = articles
            .map((article, index) => ({ ...article, _originalIndex: index }))
            .sort((a, b) => {
                const aTime = parseArticleDate(a.date);
                const bTime = parseArticleDate(b.date);

                const aValid = !isNaN(aTime);
                const bValid = !isNaN(bTime);

                if (aValid && bValid) {
                    return bTime - aTime;
                }
                if (aValid && !bValid) {
                    return -1;
                }
                if (!aValid && bValid) {
                    return 1;
                }
                return b._originalIndex - a._originalIndex;
            })
            .slice(0, 12);

        // Simple container lookup by ID
        const latestNewsRow = document.getElementById('latestNewsRow');
        if (!latestNewsRow) {
            console.error('Latest news container (#latestNewsRow) not found');
            return;
        }

        // Clear existing content
        latestNewsRow.innerHTML = '';

        // Create the latest news items
        let adsAdded = false;
        latestArticles.forEach((article, index) => {
            const colDiv = document.createElement('div');
            // 3 kolom per baris - konsisten & rapi
            colDiv.className = 'col-lg-4 col-md-6 col-sm-12 mb-4';
            
            // Gunakan judul penuh (tanpa truncate)
            const titleText = article.title || 'Tanpa Judul';
            const excerptText = truncateText(article.excerpt || '', 80);
            
            const articleHtml = `
                <div class="latest-news-card bg-white border" style="height: 100%; display: flex; flex-direction: column;">
                    <a href="${article.url}" class="flex-shrink-0">
                        <img class="img-fluid w-100" src="${article.image || 'img/placeholder.jpg'}" alt="${article.title}">
                    </a>
                    <div class="p-3 flex-grow-1 d-flex flex-column">
                        <div class="mb-2">
                            <a class="badge badge-primary badge-sm" href="news.html?category=${encodeURIComponent(article.category || 'News')}">${article.category || 'News'}</a>
                            <span class="text-muted ml-2"><small>${article.date || 'No date'}</small></span>
                        </div>
                        <a href="${article.url}" class="article-title text-secondary text-uppercase font-weight-bold mb-2">${titleText}</a>
                        <p class="article-excerpt text-muted small mb-3">${excerptText}</p>
                        <div class="article-meta mt-auto d-flex align-items-center">
                              <img class="rounded-circle mr-2" src="img/pp.png" alt="Author">
                            <small class="text-muted">${article.author || ''}</small>
                        </div>
                    </div>
                </div>
            `;
            
            colDiv.innerHTML = articleHtml;
            latestNewsRow.appendChild(colDiv);
        });

        console.log('✅ Latest news loaded successfully');

    } catch (error) {
        console.error('❌ Error loading latest news:', error);
    }
}

// Load latest news when DOM is ready
document.addEventListener('DOMContentLoaded', loadLatestNews);
