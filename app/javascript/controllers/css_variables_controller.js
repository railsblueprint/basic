import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
    connect() {
        const controller = this;

        var observer = new MutationObserver(function (mutations) {
            mutations.forEach(function (mutationRecord) {
                // It need some time to load refresh stylesheet.
                setTimeout(() => {
                    controller.refresh();
                }, 500)
            });
        });
        $("link[rel=stylesheet]").each((_, e) => {
            observer.observe(e, {attributes: true});
        })

        this.refresh();
    }

    refresh() {
        const styles = getComputedStyle(document.documentElement, null)

        $(this.element).find("[data-variable]").each((i, e) => {
            const variableName = $(e).data("variable");
            const variableValue = styles.getPropertyValue(variableName);
            $(e).html(variableValue);
        })
    }
}
