(function () {
    "use strict";

    var state = {
        server: null,
        queries: [],
        selected: null,
        result: null,
        tableIndex: 0,
        currentView: "library",
        selectedSource: "",
        activeQueryOperation: null,
        activeShellOperation: null,
        collapsedFolders: readSet("ulp.web.collapsedFolders"),
        shellHistory: readArray("ulp.web.shellHistory"),
        shellHistoryIndex: 0,
        aiMessages: readArray("ulp.web.aiMessages"),
        resultGrid: null
    };
    var elements = {};

    document.addEventListener("DOMContentLoaded", function () {
        ["applicationLayout", "navigationToggle", "topNavigationToggle", "primaryNavigation", "mobileOverlay", "sidebarClose", "serverMode", "querySearch", "queryList", "status", "librarySidebar",
            "libraryView", "adhocView", "shellView", "aiView", "serverView", "adhocNav", "shellNav", "aiNav", "queryTitle", "queryDescription", "queryMetadata",
            "savedParametersPanel", "parameterEditor", "savedParametersAdvanced", "savedParameterJsonPanel", "savedParameterJson", "savedParameterJsonError", "applySavedParameterJson",
            "sourcePanel", "querySource", "queryDirty", "openQueryWindow", "newQuery", "duplicateQuery", "deleteQuery", "reloadQuery", "resetQuery", "saveQuery", "runSaved", "stopQuery", "resultSummary", "adhocSql", "resetAdhoc", "adhocParameterEditor", "stopAdhoc",
            "addAdhocParameter", "adhocParametersAdvanced", "adhocParameterJsonPanel", "adhocParameters", "adhocParameterJsonError", "applyAdhocParameterJson", "runAdhoc",
            "shellOutput", "shellInput", "runShell", "stopShell", "clearShell", "aiMessages", "aiPrompt", "sendAi", "clearAi", "aiModel", "serverInformation", "resultsPanel",
            "resultsContent", "resultTable", "resultGrid", "collapseResults", "expandResults", "closeResults"]
            .forEach(function (id) { elements[id] = document.getElementById(id); });

        document.querySelectorAll("[data-view]").forEach(function (button) {
            button.addEventListener("click", function () {
                showView(button.getAttribute("data-view"));
                if (window.innerWidth <= 760) setTopNavigationCollapsed(true);
            });
        });
        initializeCollapsibles();
        initializeNavigation();
        initializeParameterEditors();
        initializeResults();

        elements.querySearch.addEventListener("input", renderQueryList);
        elements.runSaved.addEventListener("click", runSaved);
        elements.runAdhoc.addEventListener("click", runAdhoc);
        elements.stopQuery.addEventListener("click", function () { cancelOperation("query"); });
        elements.stopAdhoc.addEventListener("click", function () { cancelOperation("query"); });
        elements.saveQuery.addEventListener("click", saveSelected);
        elements.reloadQuery.addEventListener("click", reloadSelected);
        elements.resetQuery.addEventListener("click", resetSelectedEdits);
        elements.querySource.addEventListener("input", updateQueryDirtyState);
        elements.resetAdhoc.addEventListener("click", resetAdhocEditor);
        elements.openQueryWindow.addEventListener("click", openSelectedInNewTab);
        elements.newQuery.addEventListener("click", createQuery);
        elements.duplicateQuery.addEventListener("click", duplicateSelected);
        elements.deleteQuery.addEventListener("click", deleteSelected);
        elements.resultTable.addEventListener("change", function () { state.tableIndex = Number(elements.resultTable.value); renderResultTable(); });
        elements.runShell.addEventListener("click", runShell);
        elements.stopShell.addEventListener("click", function () { cancelOperation("shell"); });
        elements.clearShell.addEventListener("click", clearShell);
        elements.shellInput.addEventListener("keydown", handleShellKey);
        elements.sendAi.addEventListener("click", sendAi);
        elements.clearAi.addEventListener("click", clearAi);
        document.addEventListener("keydown", handleApplicationKey);
        window.addEventListener("resize", updateGridDimensions);

        if (!elements.adhocParameterEditor.children.length) addAdhocParameterRow("", "", "text");
        renderShellHistoryIntro();
        renderAiMessages();
        initialize();
    });

    async function initialize() {
        try {
            state.server = await api("/api/server");
            elements.serverMode.textContent = spaced(state.server.mode) + (state.server.https ? " · HTTPS" : " · HTTP");
            applyPermissions();
            renderServerInformation();
            await refreshQueries(queryIdFromLocation());
            setStatus("Ready.", "success");
        } catch (error) { setStatus(error.message, "error"); }
    }

    function permission(name) { return !!(state.server && state.server.permissions && state.server.permissions[name]); }

    function applyPermissions() {
        toggleHidden(elements.adhocNav, !permission("RunAdHocQueries"));
        toggleHidden(elements.shellNav, !(permission("ExecuteShellCommands") && state.server.shellAvailable));
        toggleHidden(elements.aiNav, !permission("UseAi"));
        toggleHidden(elements.newQuery, !permission("CreateQueries"));
        toggleHidden(elements.openQueryWindow, !state.selected);
        toggleHidden(elements.saveQuery, !state.selected || !permission("EditQueries"));
        toggleHidden(elements.reloadQuery, !state.selected || !permission("ViewQuerySource"));
        toggleHidden(elements.resetQuery, !state.selected || !permission("EditQueries"));
        toggleHidden(elements.deleteQuery, !state.selected || !permission("DeleteQueries"));
        toggleHidden(elements.duplicateQuery, !state.selected || !permission("CreateQueries"));
        toggleHidden(elements.sourcePanel, !state.selected || !permission("ViewQuerySource"));
        toggleHidden(elements.runSaved, !permission("RunQueries"));
        elements.querySource.readOnly = !permission("EditQueries");
        elements.aiPrompt.disabled = !state.server.aiAvailable;
        elements.sendAi.disabled = !state.server.aiAvailable;
        elements.aiModel.textContent = state.server.aiAvailable ? "Model: " + (state.server.aiModel || "configured provider") : "Not configured for this server run.";
        renderAiMessages();
    }

    async function refreshQueries(preferredId) {
        state.queries = await api("/api/queries");
        renderQueryList();
        if (preferredId) await selectQuery(preferredId);
        else if (state.selected && !state.queries.some(function (item) { return item.Id === state.selected.Id; })) clearSelection();
    }

    function renderQueryList() {
        var filter = elements.querySearch.value.trim().toLowerCase();
        var queries = state.queries.filter(function (query) {
            return !filter || [query.Title, query.Description, query.Folder, query.Category, query.Id, (query.Commands || []).join(" ")].join(" ").toLowerCase().indexOf(filter) >= 0;
        });
        elements.queryList.replaceChildren();
        if (!queries.length) {
            var empty = document.createElement("div");
            empty.className = "empty-state";
            empty.textContent = "No matching queries.";
            elements.queryList.appendChild(empty);
            return;
        }

        var root = createFolderNode("", "");
        queries.forEach(function (query) {
            var folder = normalizedFolder(query);
            var current = root;
            if (folder) {
                folder.split("/").filter(Boolean).forEach(function (name) {
                    var fullPath = current.path ? current.path + "/" + name : name;
                    if (!current.folders[name]) current.folders[name] = createFolderNode(name, fullPath);
                    current = current.folders[name];
                });
            }
            current.queries.push(query);
        });
        appendFolderContents(elements.queryList, root, !!filter);
    }

    function createFolderNode(name, path) { return { name: name, path: path, folders: {}, queries: [] }; }
    function normalizedFolder(query) {
        var folder = String(query.Folder || "").replace(/\\/g, "/").replace(/^\/+|\/+$/g, "");
        if (folder) return folder;
        var id = String(query.Id || "").replace(/\\/g, "/");
        var separator = id.lastIndexOf("/");
        return separator < 0 ? "" : id.substring(0, separator);
    }
    function folderCount(node) {
        return node.queries.length + Object.keys(node.folders).reduce(function (sum, name) { return sum + folderCount(node.folders[name]); }, 0);
    }
    function appendFolderContents(container, node, filtered) {
        node.queries.sort(querySort).forEach(function (query) { container.appendChild(createQueryButton(query)); });
        Object.keys(node.folders).sort(function (a, b) { return a.localeCompare(b); }).forEach(function (name) {
            var child = node.folders[name];
            var details = document.createElement("details");
            details.className = "query-folder";
            details.open = filtered || !state.collapsedFolders.has(child.path);
            var summary = document.createElement("summary");
            var label = document.createElement("span"); label.textContent = child.name;
            var count = document.createElement("span"); count.className = "folder-count"; count.textContent = folderCount(child).toLocaleString();
            summary.append(label, count);
            var children = document.createElement("div"); children.className = "folder-children";
            appendFolderContents(children, child, filtered);
            details.append(summary, children);
            details.addEventListener("toggle", function () {
                if (details.open) state.collapsedFolders.delete(child.path); else state.collapsedFolders.add(child.path);
                writeSet("ulp.web.collapsedFolders", state.collapsedFolders);
            });
            container.appendChild(details);
        });
    }
    function querySort(left, right) { return String(left.Title || left.Id).localeCompare(String(right.Title || right.Id)); }
    function createQueryButton(query) {
        var button = document.createElement("button");
        button.type = "button";
        button.className = "query-item" + (state.selected && state.selected.Id === query.Id ? " active" : "");
        var title = document.createElement("strong"); title.textContent = query.Title || query.Id;
        var detail = document.createElement("small"); detail.textContent = (query.Commands || []).length ? "Command: " + query.Commands[0] : query.Description || query.Id;
        button.title = query.Description || query.Id;
        button.append(title, detail);
        button.addEventListener("click", function () { selectQuery(query.Id); });
        return button;
    }

    async function selectQuery(id) {
        if (state.selected && state.selected.Id !== id && sourceIsDirty()
            && !window.confirm("Discard unsaved changes to '" + (state.selected.Title || state.selected.Id) + "' and open another query?")) return;
        try {
            state.selected = await api("/api/query?id=" + encodeURIComponent(id));
            renderSelected();
            renderQueryList();
            showView("library");
            document.title = (state.selected.Title || state.selected.Id) + " — Universal Log Parser";
            if (window.innerWidth <= 760) setSidebarCollapsed(true);
        } catch (error) { setStatus(error.message, "error"); }
    }

    function renderSelected() {
        var query = state.selected;
        elements.queryTitle.textContent = query.Title || query.Id;
        elements.queryDescription.textContent = query.Description || "No description supplied.";
        elements.queryMetadata.replaceChildren();
        addMetadata("ID: " + query.Id);
        if (query.Folder) addMetadata("Folder: " + query.Folder);
        if (query.Provider) addMetadata("Provider: " + query.Provider);
        (query.Commands || []).forEach(function (command) { addMetadata("Command: " + command); });
        renderSavedParameters(query.Parameters || {});
        state.selectedSource = query.Source || "";
        elements.querySource.value = state.selectedSource;
        updateQueryDirtyState();
        elements.runSaved.disabled = false;
        applyPermissions();
    }

    function renderSavedParameters(parameters) {
        elements.parameterEditor.replaceChildren();
        var names = Object.keys(parameters);
        toggleHidden(elements.savedParametersPanel, names.length === 0);
        names.forEach(function (name) {
            var wrapper = document.createElement("div"); wrapper.className = "parameter";
            var label = document.createElement("label"); label.textContent = name; label.htmlFor = "saved-param-" + safeId(name);
            var input = document.createElement("input"); input.id = label.htmlFor; input.value = parameters[name] == null ? "" : parameters[name]; input.setAttribute("data-parameter", name);
            var hint = document.createElement("span"); hint.className = "parameter-hint"; hint.textContent = "SQLite parameter @" + name;
            input.addEventListener("input", syncSavedJsonFromFields);
            wrapper.append(label, input, hint);
            elements.parameterEditor.appendChild(wrapper);
        });
        syncSavedJsonFromFields();
    }

    function clearSelection() {
        state.selected = null;
        elements.queryTitle.textContent = "Choose a saved query";
        elements.queryDescription.textContent = "Select a query from the folder tree.";
        elements.queryMetadata.replaceChildren();
        elements.parameterEditor.replaceChildren();
        toggleHidden(elements.savedParametersPanel, true);
        state.selectedSource = "";
        elements.querySource.value = "";
        updateQueryDirtyState();
        document.title = "Universal Log Parser";
        elements.runSaved.disabled = true;
        applyPermissions();
        renderQueryList();
    }

    async function runSaved() {
        if (!state.selected) return;
        try { await execute("/api/query/run?id=" + encodeURIComponent(state.selected.Id), { Parameters: savedParametersFromFields() }, "saved query '" + state.selected.Id + "'"); }
        catch (error) { /* execute already presents and clears failed result state. */ }
    }

    async function runAdhoc() {
        try { await execute("/api/query/adhoc", { Sql: elements.adhocSql.value, Parameters: adhocParametersFromFields() }, "ad-hoc query"); }
        catch (error) { setStatus(error.message, "error"); }
    }

    async function execute(url, body, label) {
        label = label || "query";
        var operation = beginOperation("query");
        setStatus("Running " + label + "…");
        clearResults("Previous results cleared while the query is running.");
        elements.runSaved.disabled = true;
        elements.runAdhoc.disabled = true;
        try {
            state.result = await api(url, { method: "POST", body: JSON.stringify(body) }, operation);
            state.tableIndex = 0;
            renderResults();
            var suffix = state.result.Truncated ? " (display limit reached)" : "";
            setStatus((state.result.QueryTitle || label) + " completed: " + state.result.RowCount.toLocaleString() + " rows in " + state.result.DurationMilliseconds.toLocaleString() + " ms" + suffix + ".", "success");
            if (state.selected) {
                var pendingSource = sourceIsDirty() ? elements.querySource.value : null;
                try {
                    await refreshQueries(state.selected.Id);
                    if (pendingSource !== null) {
                        elements.querySource.value = pendingSource;
                        updateQueryDirtyState();
                    }
                }
                catch (refreshError) { setStatus("Query completed, but the Query library could not be refreshed: " + refreshError.message, "warning"); }
            }
            return state.result;
        } catch (error) { clearResults("No current results. The " + label + " failed."); setStatus("Could not run " + label + ": " + error.message, "error"); throw error; }
        finally { endOperation("query", operation); elements.runSaved.disabled = !state.selected || !permission("RunQueries"); elements.runAdhoc.disabled = !permission("RunAdHocQueries"); }
    }

    function clearResults(message) {
        state.result = null;
        state.tableIndex = 0;
        if (state.resultGrid) { state.resultGrid.dispose(); state.resultGrid = null; }
        $(elements.resultGrid).empty();
        elements.resultTable.replaceChildren();
        elements.resultSummary.textContent = message || "No current results.";
        elements.resultsPanel.classList.remove("expanded");
        document.body.classList.remove("results-expanded");
        elements.resultsPanel.classList.add("hidden");
    }

    function renderResults() {
        elements.resultsPanel.classList.remove("hidden", "collapsed");
        elements.collapseResults.setAttribute("aria-expanded", "true");
        elements.resultTable.replaceChildren();
        (state.result.Tables || []).forEach(function (table, index) {
            var option = document.createElement("option"); option.value = index; option.textContent = table.Name + " (" + table.Rows.length.toLocaleString() + ")";
            elements.resultTable.appendChild(option);
        });
        elements.resultSummary.textContent = state.result.RowCount.toLocaleString() + " row(s)" + (state.result.Truncated ? ", truncated" : "");
        renderResultTable();
        elements.resultsPanel.scrollIntoView({ behavior: "smooth", block: "start" });
    }

    function renderResultTable() {
        var table = state.result && state.result.Tables ? state.result.Tables[state.tableIndex] : null;
        var rows = [];
        var columns = [];
        if (table) {
            columns = table.Columns.map(function (column) { return { dataField: column.Name, caption: column.Name, dataType: gridType(column.Type) }; });
            rows = table.Rows.map(function (values) {
                var row = {};
                table.Columns.forEach(function (column, index) { row[column.Name] = values[index]; });
                return row;
            });
        }
        if (state.resultGrid) state.resultGrid.dispose();
        $(elements.resultGrid).empty().dxDataGrid({
            dataSource: rows,
            columns: columns,
            showBorders: true,
            columnAutoWidth: true,
            allowColumnResizing: true,
            allowColumnReordering: true,
            columnResizingMode: "widget",
            rowAlternationEnabled: true,
            filterRow: { visible: true },
            headerFilter: { visible: true },
            searchPanel: { visible: true, width: 260, placeholder: "Search results…" },
            sorting: { mode: "multiple" },
            scrolling: { mode: "virtual", rowRenderingMode: "virtual", useNative: true, showScrollbar: "always" },
            paging: { enabled: false },
            pager: { visible: false },
            selection: { mode: "multiple", showCheckBoxesMode: "onClick" },
            export: { enabled: true, fileName: "ulp-results" },
            columnChooser: { enabled: true },
            wordWrapEnabled: false
        });
        state.resultGrid = $(elements.resultGrid).dxDataGrid("instance");
        updateGridDimensions();
    }

    function initializeResults() {
        elements.collapseResults.addEventListener("click", function () {
            var collapsed = elements.resultsPanel.classList.toggle("collapsed");
            elements.collapseResults.setAttribute("aria-expanded", String(!collapsed));
        });
        elements.expandResults.addEventListener("click", function () { setResultsExpanded(!elements.resultsPanel.classList.contains("expanded")); });
        elements.closeResults.addEventListener("click", function () { setResultsExpanded(false); elements.resultsPanel.classList.add("hidden"); });
    }
    function setResultsExpanded(expanded) {
        elements.resultsPanel.classList.toggle("expanded", expanded);
        document.body.classList.toggle("results-expanded", expanded);
        elements.expandResults.setAttribute("aria-pressed", String(expanded));
        elements.expandResults.textContent = expanded ? "Restore" : "Expand";
        setTimeout(updateGridDimensions, 10);
    }
    function updateGridDimensions() {
        if (state.resultGrid) state.resultGrid.updateDimensions();
    }

    function queryIdFromLocation() {
        try { return new URL(window.location.href).searchParams.get("query"); }
        catch (error) { return null; }
    }

    function openSelectedInNewTab() {
        if (!state.selected) return;
        var url = new URL(window.location.href);
        url.search = "";
        url.hash = "";
        url.searchParams.set("query", state.selected.Id);
        window.open(url.toString(), "_blank", "noopener");
    }

    function initializeParameterEditors() {
        elements.savedParametersAdvanced.addEventListener("click", function () { toggleJsonPanel(elements.savedParameterJsonPanel, elements.savedParametersAdvanced, syncSavedJsonFromFields); });
        elements.applySavedParameterJson.addEventListener("click", applySavedJson);
        elements.savedParameterJson.addEventListener("input", function () { validateJsonEditor(elements.savedParameterJson, elements.savedParameterJsonError); });
        elements.addAdhocParameter.addEventListener("click", function () { addAdhocParameterRow("", "", "text"); });
        elements.adhocParametersAdvanced.addEventListener("click", function () { toggleJsonPanel(elements.adhocParameterJsonPanel, elements.adhocParametersAdvanced, syncAdhocJsonFromFields); });
        elements.applyAdhocParameterJson.addEventListener("click", applyAdhocJson);
        elements.adhocParameters.addEventListener("input", function () { validateJsonEditor(elements.adhocParameters, elements.adhocParameterJsonError); });
    }
    function toggleJsonPanel(panel, button, beforeShow) {
        var showing = panel.classList.contains("hidden");
        if (showing && beforeShow) beforeShow();
        panel.classList.toggle("hidden", !showing);
        button.textContent = showing ? "Hide JSON" : "Advanced JSON";
    }
    function savedParametersFromFields() {
        var values = {};
        elements.parameterEditor.querySelectorAll("[data-parameter]").forEach(function (input) { values[input.getAttribute("data-parameter")] = input.value; });
        return values;
    }
    function syncSavedJsonFromFields() { elements.savedParameterJson.value = JSON.stringify(savedParametersFromFields(), null, 2); clearJsonError(elements.savedParameterJsonError); }
    function applySavedJson() {
        var values = parseJsonObject(elements.savedParameterJson, elements.savedParameterJsonError);
        if (!values) return;
        elements.parameterEditor.querySelectorAll("[data-parameter]").forEach(function (input) {
            var name = input.getAttribute("data-parameter");
            if (Object.prototype.hasOwnProperty.call(values, name)) input.value = valueToInput(values[name]);
        });
        syncSavedJsonFromFields();
    }

    function addAdhocParameterRow(name, value, type) {
        var row = document.createElement("div"); row.className = "parameter-row";
        var nameInput = document.createElement("input"); nameInput.type = "text"; nameInput.placeholder = "name"; nameInput.value = name || ""; nameInput.className = "parameter-name"; nameInput.setAttribute("aria-label", "Parameter name");
        var valueInput = document.createElement("input"); valueInput.type = type === "boolean" ? "text" : type === "number" ? "number" : "text"; valueInput.placeholder = "value"; valueInput.value = value == null ? "" : value; valueInput.className = "parameter-value"; valueInput.setAttribute("aria-label", "Parameter value");
        var typeSelect = document.createElement("select"); typeSelect.className = "parameter-type"; typeSelect.setAttribute("aria-label", "Parameter type");
        ["text", "number", "boolean", "null"].forEach(function (candidate) { var option = document.createElement("option"); option.value = candidate; option.textContent = candidate; typeSelect.appendChild(option); });
        typeSelect.value = type || "text";
        typeSelect.addEventListener("change", function () { valueInput.disabled = typeSelect.value === "null"; valueInput.type = typeSelect.value === "number" ? "number" : "text"; syncAdhocJsonFromFields(); });
        var remove = document.createElement("button"); remove.type = "button"; remove.className = "remove-parameter"; remove.textContent = "×"; remove.setAttribute("aria-label", "Remove parameter");
        remove.addEventListener("click", function () { row.remove(); syncAdhocJsonFromFields(); });
        [nameInput, valueInput].forEach(function (input) { input.addEventListener("input", syncAdhocJsonFromFields); });
        row.append(nameInput, valueInput, typeSelect, remove);
        elements.adhocParameterEditor.appendChild(row);
        valueInput.disabled = typeSelect.value === "null";
    }
    function adhocParametersFromFields() {
        var result = {};
        elements.adhocParameterEditor.querySelectorAll(".parameter-row").forEach(function (row) {
            var name = row.querySelector(".parameter-name").value.trim().replace(/^[@:$]/, "");
            if (!name) return;
            var type = row.querySelector(".parameter-type").value;
            var value = row.querySelector(".parameter-value").value;
            if (type === "number") {
                if (value.trim() === "" || isNaN(Number(value))) throw new Error("Parameter '" + name + "' requires a number.");
                result[name] = String(Number(value));
            } else if (type === "boolean") result[name] = /^(true|1|yes|on)$/i.test(value) ? "true" : "false";
            else if (type === "null") result[name] = "null";
            else result[name] = value;
        });
        return result;
    }
    function syncAdhocJsonFromFields() {
        try { elements.adhocParameters.value = JSON.stringify(adhocParametersFromFields(), null, 2); clearJsonError(elements.adhocParameterJsonError); }
        catch (error) { elements.adhocParameterJsonError.textContent = error.message; }
    }
    function applyAdhocJson() {
        var values = parseJsonObject(elements.adhocParameters, elements.adhocParameterJsonError);
        if (!values) return;
        elements.adhocParameterEditor.replaceChildren();
        Object.keys(values).forEach(function (name) {
            var value = values[name];
            var type = value === null ? "null" : typeof value === "number" ? "number" : typeof value === "boolean" ? "boolean" : "text";
            addAdhocParameterRow(name, valueToInput(value), type);
        });
        if (!Object.keys(values).length) addAdhocParameterRow("", "", "text");
        syncAdhocJsonFromFields();
    }
    function parseJsonObject(editor, errorElement) {
        try {
            var value = JSON.parse(editor.value || "{}");
            if (!value || Array.isArray(value) || typeof value !== "object") throw new Error("Use a JSON object containing parameter names and values.");
            clearJsonError(errorElement);
            editor.value = JSON.stringify(value, null, 2);
            return value;
        } catch (error) { errorElement.textContent = error.message; return null; }
    }
    function validateJsonEditor(editor, errorElement) { parseJsonObject({ value: editor.value }, errorElement); }
    function clearJsonError(element) { element.textContent = ""; }
    function valueToInput(value) { return value == null ? "" : String(value); }

    function initializeCollapsibles() {
        var saved = readObject("ulp.web.panels");
        document.querySelectorAll(".collapsible").forEach(function (panel) {
            var key = panel.getAttribute("data-panel");
            var button = panel.querySelector(".collapse-button");
            if (!button) return;
            if (key && saved[key] === true) setPanelCollapsed(panel, button, true);
            button.addEventListener("click", function () {
                var collapsed = !panel.classList.contains("collapsed");
                setPanelCollapsed(panel, button, collapsed);
                if (key) { saved[key] = collapsed; writeObject("ulp.web.panels", saved); }
            });
        });
    }
    function setPanelCollapsed(panel, button, collapsed) { panel.classList.toggle("collapsed", collapsed); button.setAttribute("aria-expanded", String(!collapsed)); }

    function initializeNavigation() {
        var collapsed = localStorage.getItem("ulp.web.sidebarCollapsed") === "true";
        setSidebarCollapsed(collapsed);
        var storedTopNavigation = localStorage.getItem("ulp.web.topNavigationCollapsed");
        setTopNavigationCollapsed(storedTopNavigation === null ? window.innerWidth <= 760 : storedTopNavigation === "true");
        elements.navigationToggle.addEventListener("click", function () {
            if (state.currentView !== "library") { showView("library"); setSidebarCollapsed(false); }
            else setSidebarCollapsed(!elements.applicationLayout.classList.contains("sidebar-collapsed"));
        });
        elements.topNavigationToggle.addEventListener("click", function () { setTopNavigationCollapsed(!document.querySelector(".topbar").classList.contains("nav-collapsed")); });
        elements.sidebarClose.addEventListener("click", function () { setSidebarCollapsed(true); });
        elements.mobileOverlay.addEventListener("click", function () { setSidebarCollapsed(true); });
    }
    function setTopNavigationCollapsed(collapsed) {
        var topbar = document.querySelector(".topbar");
        topbar.classList.toggle("nav-collapsed", collapsed);
        elements.topNavigationToggle.setAttribute("aria-expanded", String(!collapsed));
        elements.topNavigationToggle.textContent = collapsed ? "Sections" : "Hide sections";
        localStorage.setItem("ulp.web.topNavigationCollapsed", String(collapsed));
    }
    function setSidebarCollapsed(collapsed) {
        elements.applicationLayout.classList.toggle("sidebar-collapsed", collapsed);
        elements.navigationToggle.setAttribute("aria-expanded", String(!collapsed));
        localStorage.setItem("ulp.web.sidebarCollapsed", String(collapsed));
        elements.mobileOverlay.classList.toggle("hidden", collapsed || window.innerWidth > 760);
        setTimeout(updateGridDimensions, 180);
    }

    async function runShell() {
        var command = elements.shellInput.value.trim();
        if (!command) return;
        if (command === ".clear") { clearShell(); elements.shellInput.value = ""; return; }
        appendShell(command, "shell-command");
        rememberShellCommand(command);
        elements.shellInput.value = "";
        elements.runShell.disabled = true;
        var operation = beginOperation("shell");
        try {
            var response = await api("/api/shell", { method: "POST", body: JSON.stringify({ Command: command }) }, operation);
            if (response.Message) appendShell(response.Message, "");
            if (response.Result) { state.result = response.Result; state.tableIndex = 0; renderResults(); appendShell("Result opened in the grid (" + response.Result.RowCount + " rows).", ""); }
        } catch (error) { appendShell(error.message, "shell-error"); }
        finally { endOperation("shell", operation); elements.runShell.disabled = !permission("ExecuteShellCommands"); elements.shellInput.focus(); }
    }
    function handleShellKey(event) {
        if (event.key === "Enter") { event.preventDefault(); runShell(); return; }
        if (event.key === "ArrowUp" && state.shellHistory.length) { event.preventDefault(); state.shellHistoryIndex = Math.max(0, state.shellHistoryIndex - 1); elements.shellInput.value = state.shellHistory[state.shellHistoryIndex] || ""; }
        if (event.key === "ArrowDown" && state.shellHistory.length) { event.preventDefault(); state.shellHistoryIndex = Math.min(state.shellHistory.length, state.shellHistoryIndex + 1); elements.shellInput.value = state.shellHistory[state.shellHistoryIndex] || ""; }
    }
    function rememberShellCommand(command) {
        if (state.shellHistory[state.shellHistory.length - 1] !== command) state.shellHistory.push(command);
        state.shellHistory = state.shellHistory.slice(-100);
        state.shellHistoryIndex = state.shellHistory.length;
        writeArray("ulp.web.shellHistory", state.shellHistory);
    }
    function appendShell(text, className) { var line = document.createElement("div"); line.className = "shell-entry " + (className || ""); line.textContent = text; elements.shellOutput.appendChild(line); elements.shellOutput.scrollTop = elements.shellOutput.scrollHeight; }
    function clearShell() { elements.shellOutput.replaceChildren(); renderShellHistoryIntro(); }
    function renderShellHistoryIntro() { appendShell("Safe ULP web shell. Type .help for available commands; .clear clears this browser output.", ""); }

    async function sendAi() {
        if (!state.server || !state.server.aiAvailable) { setStatus("AI Chat is not configured for this server run.", "error"); return; }
        var message = elements.aiPrompt.value.trim();
        if (!message) return;
        var previousMessages = state.aiMessages.slice(-12);
        appendAiMessage("user", message);
        elements.aiPrompt.value = "";
        elements.sendAi.disabled = true;
        try {
            var response = await api("/api/ai", { method: "POST", body: JSON.stringify({ Message: message, Messages: previousMessages }) });
            appendAiMessage("assistant", response.Sql || response.Message || "No SQL was returned.", response.Sql);
        } catch (error) { appendAiMessage("assistant", "AI request failed: " + error.message); }
        finally { elements.sendAi.disabled = false; }
    }
    function appendAiMessage(role, text, sql) {
        state.aiMessages.push({ role: role, content: text });
        state.aiMessages = state.aiMessages.slice(-30);
        writeArray("ulp.web.aiMessages", state.aiMessages);
        renderAiMessage(role, text, sql);
        elements.aiMessages.scrollTop = elements.aiMessages.scrollHeight;
    }
    function renderAiMessages() {
        elements.aiMessages.replaceChildren();
        if (!state.server || !state.server.aiAvailable)
            renderAiMessage("assistant", "AI Chat is experimental and is not configured for this server run. Start the web server with --web-ai and an API key to enable it.");
        else if (!state.aiMessages.length) renderAiMessage("assistant", "Ask for a query using the current SQLite schemas. Generated SQL is never executed automatically.");
        else state.aiMessages.forEach(function (message) { renderAiMessage(message.role, message.content, message.role === "assistant" && /^\s*(SELECT|WITH|PRAGMA|EXPLAIN)\b/i.test(message.content) ? message.content : null); });
    }
    function renderAiMessage(role, text, sql) {
        var message = document.createElement("div"); message.className = "ai-message " + role + (sql ? " ai-sql" : ""); message.textContent = text;
        if (sql) { var button = document.createElement("button"); button.type = "button"; button.className = "secondary"; button.textContent = "Open in Ad-hoc editor"; button.addEventListener("click", function () { elements.adhocSql.value = sql; showView("adhoc"); }); message.appendChild(document.createElement("br")); message.appendChild(button); }
        elements.aiMessages.appendChild(message);
    }
    function clearAi() { state.aiMessages = []; writeArray("ulp.web.aiMessages", state.aiMessages); renderAiMessages(); }

    async function createQuery() {
        var id = window.prompt("New query ID (a relative path such as My Queries/example.sql):");
        if (!id) return;
        var title = window.prompt("Query title:", id.replace(/\.sql$/i, "")) || "";
        try { var created = await api("/api/query", { method: "POST", body: JSON.stringify({ Id: id, Title: title, Source: "SELECT 1 AS value;\n" }) }); await refreshQueries(created.Id); setStatus("Saved query created.", "success"); }
        catch (error) { await recoverQueryState(error, state.selected && state.selected.Id); }
    }
    async function saveSelected() {
        if (!state.selected) return;
        if (!sourceIsDirty()) { setStatus("No changes to save for '" + (state.selected.Title || state.selected.Id) + "'."); return; }
        if (!window.confirm("Save changes to '" + (state.selected.Title || state.selected.Id) + "'? This replaces the saved SQL source.")) return;
        try { state.selected = await api("/api/query?id=" + encodeURIComponent(state.selected.Id), { method: "PUT", body: JSON.stringify({ Source: elements.querySource.value }) }); renderSelected(); await refreshQueries(state.selected.Id); setStatus("Saved query updated.", "success"); }
        catch (error) { await recoverQueryState(error, state.selected && state.selected.Id); }
    }
    async function reloadSelected() {
        if (!state.selected) return;
        if (sourceIsDirty() && !window.confirm("Discard local edits and reload '" + (state.selected.Title || state.selected.Id) + "' from the Query library?")) return;
        var id = state.selected.Id;
        try { state.selected = await api("/api/query?id=" + encodeURIComponent(id)); renderSelected(); await refreshQueries(id); setStatus("Reloaded saved query '" + id + "'.", "success"); }
        catch (error) { await recoverQueryState(error, id); }
    }
    function resetSelectedEdits() {
        if (!state.selected || !sourceIsDirty()) return;
        if (!window.confirm("Discard unsaved edits to '" + (state.selected.Title || state.selected.Id) + "'?")) return;
        elements.querySource.value = state.selectedSource;
        updateQueryDirtyState();
        setStatus("Unsaved edits were discarded.");
    }
    function sourceIsDirty() { return !!state.selected && elements.querySource.value !== state.selectedSource; }
    function updateQueryDirtyState() {
        var dirty = sourceIsDirty();
        toggleHidden(elements.queryDirty, !dirty);
        elements.resetQuery.disabled = !dirty;
        elements.saveQuery.disabled = !dirty;
    }
    function resetAdhocEditor() {
        var hasParameters = Array.prototype.some.call(elements.adhocParameterEditor.querySelectorAll(".parameter-row"), function (row) {
            return row.querySelector(".parameter-name").value.trim() || row.querySelector(".parameter-value").value.trim();
        });
        if ((elements.adhocSql.value.trim() || hasParameters)
            && !window.confirm("Clear the ad-hoc SQL and all parameters?")) return;
        elements.adhocSql.value = "";
        elements.adhocParameterEditor.replaceChildren();
        addAdhocParameterRow("", "", "text");
        syncAdhocJsonFromFields();
        clearResults("No current results.");
        setStatus("Ad-hoc editor reset.");
    }
    async function duplicateSelected() {
        if (!state.selected) return;
        var id = window.prompt("ID for the duplicate:", state.selected.Id.replace(/\.sql$/i, "-copy.sql"));
        if (!id) return;
        try { var duplicate = await api("/api/query/duplicate?id=" + encodeURIComponent(state.selected.Id), { method: "POST", body: JSON.stringify({ Id: id }) }); await refreshQueries(duplicate.Id); setStatus("Saved query duplicated.", "success"); }
        catch (error) { await recoverQueryState(error, state.selected && state.selected.Id); }
    }
    async function deleteSelected() {
        if (!state.selected || !window.confirm("Delete '" + state.selected.Title + "'? This removes its SQL file.")) return;
        try { await api("/api/query?id=" + encodeURIComponent(state.selected.Id), { method: "DELETE" }); clearSelection(); await refreshQueries(); setStatus("Saved query deleted.", "success"); }
        catch (error) { await recoverQueryState(error, null); }
    }

    async function recoverQueryState(operationError, preferredId) {
        try { await refreshQueries(preferredId); }
        catch (refreshError) {
            setStatus(operationError.message + " The Query library refresh also failed: " + refreshError.message, "error");
            return;
        }
        setStatus(operationError.message + " The Query library was refreshed from the server.", "error");
    }

    function renderServerInformation() {
        elements.serverInformation.replaceChildren();
        [["Mode", spaced(state.server.mode)], ["Transport", state.server.https ? "HTTPS" : "HTTP"], ["Authentication", state.server.authentication ? "Enabled" : "Disabled"],
            ["Maximum returned rows", state.server.maximumRows.toLocaleString()], ["Web shell", state.server.shellAvailable ? "Available" : "Not available"], ["AI chat", state.server.aiAvailable ? "Available · " + (state.server.aiModel || "configured") : "Not configured"]]
            .forEach(addInformationRow);
        Object.keys(state.server.permissions || {}).forEach(function (name) { addInformationRow([spaced(name), yesNo(state.server.permissions[name])]); });
    }

    function beginOperation(kind) {
        var operation = { id: newOperationId(), controller: new AbortController() };
        state[kind === "shell" ? "activeShellOperation" : "activeQueryOperation"] = operation;
        if (kind === "shell") toggleHidden(elements.stopShell, false);
        else { toggleHidden(elements.stopQuery, state.currentView !== "library"); toggleHidden(elements.stopAdhoc, state.currentView !== "adhoc"); }
        return operation;
    }
    function endOperation(kind, operation) {
        var key = kind === "shell" ? "activeShellOperation" : "activeQueryOperation";
        if (state[key] !== operation) return;
        state[key] = null;
        if (kind === "shell") toggleHidden(elements.stopShell, true);
        else { toggleHidden(elements.stopQuery, true); toggleHidden(elements.stopAdhoc, true); }
    }
    async function cancelOperation(kind) {
        var operation = state[kind === "shell" ? "activeShellOperation" : "activeQueryOperation"];
        if (!operation) return;
        try {
            await api("/api/cancel", { method: "POST", body: JSON.stringify({ OperationId: operation.id }) });
            operation.controller.abort();
            setStatus((kind === "shell" ? "Shell" : "Query") + " cancellation requested.", "warning");
        } catch (error) { setStatus("Could not cancel the request: " + error.message, "error"); }
    }
    function newOperationId() {
        if (window.crypto && typeof window.crypto.randomUUID === "function") return window.crypto.randomUUID();
        return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function (value) {
            var random = Math.random() * 16 | 0;
            return (value === "x" ? random : (random & 3 | 8)).toString(16);
        });
    }
    function addInformationRow(entry) { var key = document.createElement("div"); key.className = "key"; key.textContent = entry[0]; var value = document.createElement("div"); value.textContent = entry[1]; elements.serverInformation.append(key, value); }

    function showView(name) {
        if (!elements[name + "View"]) return;
        state.currentView = name;
        document.querySelectorAll(".view").forEach(function (view) { view.classList.add("hidden"); });
        document.querySelectorAll("[data-view]").forEach(function (button) { button.classList.toggle("active", button.getAttribute("data-view") === name); });
        elements[name + "View"].classList.remove("hidden");
        elements.applicationLayout.classList.toggle("library-hidden", name !== "library");
        elements.librarySidebar.classList.toggle("hidden", name !== "library");
        if (name === "library") elements.librarySidebar.classList.remove("hidden");
        elements.navigationToggle.setAttribute("aria-label", name === "library" ? "Toggle Query Library" : "Open Query Library");
        if (name !== "library" && window.innerWidth <= 760) setSidebarCollapsed(true);
        updateGridDimensions();
    }

    function handleApplicationKey(event) {
        if (event.key === "Escape" && elements.resultsPanel.classList.contains("expanded")) { setResultsExpanded(false); return; }
        if ((event.ctrlKey || event.metaKey) && event.key === "Enter") {
            if (state.currentView === "library" && state.selected) { event.preventDefault(); runSaved(); }
            else if (state.currentView === "adhoc") { event.preventDefault(); runAdhoc(); }
            else if (state.currentView === "ai") { event.preventDefault(); sendAi(); }
        }
    }

    async function api(url, options, operation) {
        options = options || {};
        options.headers = Object.assign({ "Accept": "application/json" }, options.headers || {});
        if (options.method && options.method !== "GET") { options.headers["Content-Type"] = "application/json"; options.headers["X-ULP-Request"] = "1"; }
        if (operation) { options.headers["X-ULP-Operation"] = operation.id; options.signal = operation.controller.signal; }
        var response;
        try { response = await fetch(url, options); }
        catch (error) {
            if (error && error.name === "AbortError") throw new Error("The request was cancelled.");
            throw new Error("Unable to reach the ULP web server. Check the connection and try again.");
        }
        var text = await response.text();
        var data = null;
        if (text) { try { data = JSON.parse(text); } catch (error) { throw new Error("The server returned an invalid response (HTTP " + response.status + ")."); } }
        if (!response.ok) throw new Error(data && data.error ? data.error : "The server rejected the request (HTTP " + response.status + ").");
        return data;
    }

    function addMetadata(text) { var item = document.createElement("span"); item.textContent = text; elements.queryMetadata.appendChild(item); }
    function setStatus(message, kind) { elements.status.textContent = message; elements.status.className = "status" + (kind ? " " + kind : ""); }
    function toggleHidden(element, hidden) { if (element) element.classList.toggle("hidden", hidden); }
    function yesNo(value) { return value ? "Yes" : "No"; }
    function spaced(value) { return String(value || "").replace(/([a-z])([A-Z])/g, "$1 $2"); }
    function safeId(value) { return String(value).replace(/[^a-zA-Z0-9_-]/g, "-"); }
    function gridType(type) { return /Int|Decimal|Double|Single/.test(type) ? "number" : /Date/.test(type) ? "date" : /Bool/.test(type) ? "boolean" : "string"; }
    function readObject(key) { try { return JSON.parse(localStorage.getItem(key) || "{}"); } catch (error) { return {}; } }
    function writeObject(key, value) { try { localStorage.setItem(key, JSON.stringify(value)); } catch (error) { } }
    function readArray(key) { try { var value = JSON.parse(sessionStorage.getItem(key) || "[]"); return Array.isArray(value) ? value : []; } catch (error) { return []; } }
    function writeArray(key, value) { try { sessionStorage.setItem(key, JSON.stringify(value)); } catch (error) { } }
    function readSet(key) { try { return new Set(JSON.parse(localStorage.getItem(key) || "[]")); } catch (error) { return new Set(); } }
    function writeSet(key, value) { try { localStorage.setItem(key, JSON.stringify(Array.from(value))); } catch (error) { } }
}());
