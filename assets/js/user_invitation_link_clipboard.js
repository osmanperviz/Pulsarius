export const UserInvitationLinkClipboardHook = {
    mounted() {
        this.handleEvent("copy_user_invitation_link", ({ link }) => {
            navigator.clipboard.writeText(link).then(() => {
                console.log("All done!"); // Or a nice tooltip or something.
            })
     })
    }
}