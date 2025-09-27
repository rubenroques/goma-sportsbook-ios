document.addEventListener('DOMContentLoaded', () => {
    const fileTreeContainer = document.getElementById('file-tree');
    const renderedContent = document.getElementById('rendered-content');
    const sourceContentPre = document.getElementById('source-content-pre');
    const sourceContentCode = sourceContentPre.querySelector('code');
    const fileNameDisplay = document.getElementById('file-name');
    const renderedBtn = document.getElementById('rendered-btn');
    const sourceBtn = document.getElementById('source-btn');

    fetch('files.json')
        .then(response => response.json())
        .then(data => {
            const fileTree = createTree(data[0].contents, '.');
            fileTreeContainer.appendChild(fileTree);
        });

    function createTree(items, basePath) {
        const ul = document.createElement('ul');
        items.forEach(item => {
            const li = document.createElement('li');
            if (item.type === 'directory') {
                li.textContent = `📁 ${item.name}`;
                li.classList.add('folder');
                if (item.contents) {
                    const childrenUl = createTree(item.contents, `${basePath}/${item.name}`);
                    childrenUl.style.display = 'none';
                    li.appendChild(childrenUl);
                    li.addEventListener('click', (e) => {
                        e.stopPropagation();
                        childrenUl.style.display = childrenUl.style.display === 'none' ? 'block' : 'none';
                    });
                }
            } else {
                li.textContent = `📄 ${item.name}`;
                li.classList.add('file');
                li.dataset.path = `${basePath}/${item.name}`;
                li.addEventListener('click', (e) => {
                    e.stopPropagation();
                    loadFile(li.dataset.path);
                });
            }
            ul.appendChild(li);
        });
        return ul;
    }

    function loadFile(path) {
        fetch(`../${path.substring(2)}`) // Go up one dir and remove leading './'
            .then(response => response.text())
            .then(text => {
                fileNameDisplay.textContent = path;
                renderedContent.innerHTML = marked(text);
                sourceContentCode.textContent = text;
            });
    }

    renderedBtn.addEventListener('click', () => {
        renderedContent.style.display = 'block';
        sourceContentPre.style.display = 'none';
        renderedBtn.classList.add('active');
        sourceBtn.classList.remove('active');
    });

    sourceBtn.addEventListener('click', () => {
        renderedContent.style.display = 'none';
        sourceContentPre.style.display = 'block';
        renderedBtn.classList.remove('active');
        sourceBtn.classList.add('active');
    });
});
