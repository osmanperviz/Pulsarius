export const TooltipInit = {
  mounted() {
    const id = this.el.getAttribute('id');
    $('#' + id).tooltip();
  },
};